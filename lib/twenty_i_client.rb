# lib/twenty_i_client.rb
require "net/http"
require "json"
require "uri"
require "base64"

class TwentyIClient
  API_BASE = ENV.fetch("TWENTYI_API_BASE", "https://api.20i.com")

  class Error < StandardError; end

  def initialize(general_key: nil)
    @general_key =
      general_key ||
      Rails.application.credentials.dig(:twenty_i, :general_key) ||
      ENV["TWENTYI_GENERAL_KEY"]

    raise Error, "Missing 20i general key. Set credentials or TWENTYI_GENERAL_KEY." if @general_key.to_s.strip.empty?

    @bearer = Base64.strict_encode64(@general_key.strip)
  end

  def reseller_id
    @reseller_id ||= begin
                       res = get("/reseller")

                       if res.is_a?(Array)
                         res.first.fetch("id") # take first reseller in the list
                       elsif res.is_a?(Hash)
                         res.fetch("id")
                       else
                         raise Error, "Unexpected response from /reseller: #{res.inspect}"
                       end
                     end
  end

  # Registers a domain. Returns the parsed JSON, or true/false if API returns a bare boolean.
  def register_domain!(payload)
    path = "/reseller/#{reseller_id}/addDomain"
    post(path, payload)
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@bearer}",
      "Accept"        => "application/json",
      "Content-Type"  => "application/json"
    }
  end

  def get(path, query: nil)
    uri = URI.join(API_BASE, path)
    uri.query = URI.encode_www_form(query) if query
    res = request(Net::HTTP::Get.new(uri, headers))
    parse_body(res)
  end

  def post(path, body_hash = {})
    uri = URI.join(API_BASE, path)
    req = Net::HTTP::Post.new(uri, headers)
    req.body = JSON.dump(body_hash)
    res = request(req)
    parse_body(res)
  end

  def request(req)
    http = Net::HTTP.new(req.uri.host, req.uri.port)
    http.use_ssl = (req.uri.scheme == "https")
    http.open_timeout = 10
    http.read_timeout = 30
    res = http.request(req)

    unless res.code.to_i.between?(200, 299)
      raise Error, "HTTP #{res.code} #{res.message} #{res.body}"
    end

    res
  end

  def parse_body(res)
    return true if res.body.strip == "true"
    return false if res.body.strip == "false"
    JSON.parse(res.body)
  rescue JSON::ParserError
    # Some endpoints may return empty body with 2xx
    {}
  end
end
