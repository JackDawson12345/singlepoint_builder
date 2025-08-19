# lib/tasks/domain_search.rake
require "net/http"
require "json"
require "uri"
require "base64"

namespace :domain do
  desc "Search domains. Usage: rake domain:search[prefix_or_name]"
  task :search, [:query] => :environment do |_, args|
    query = args[:query] or abort "Usage: rake domain:search[prefix_or_name]"

    general_key =
      Rails.application.credentials.dig(:twenty_i, :general_key) ||
      ENV["TWENTYI_GENERAL_KEY"]

    abort "Missing 20i general key. Set credentials or TWENTYI_GENERAL_KEY." if general_key.to_s.strip.empty?

    bearer = Base64.strict_encode64(general_key.strip)

    uri = URI("https://api.20i.com/domain-search/#{URI.encode_www_form_component(query)}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 20

    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{bearer}"
    req["Accept"] = "application/json"

    res = http.request(req)

    if res.code.to_i.between?(200, 299)
      puts JSON.pretty_generate(JSON.parse(res.body))
    else
      warn "HTTP #{res.code}"
      warn res.body
    end
  rescue JSON::ParserError
    warn "Non JSON response:"
    puts res.body
  end
end
