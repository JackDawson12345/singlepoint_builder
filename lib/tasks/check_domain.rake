# lib/tasks/check_domain.rake
require "net/http"
require "json"
require "base64"

namespace :domain do
  desc "rake domain:check[example.co.uk]"
  task :check, [:domain] => :environment do |_, args|
    domain  = args[:domain] or abort "Usage: rake domain:check[example.co.uk]"
    key     = ENV["TWENTYI_COMBINED_KEY"] || "c6af16834dd2bf798+cdaada63885522ef9"

    uri = URI("https://api.20i.com/domain/check?domain=#{domain}")
    req = Net::HTTP::Get.new(uri)
    # Basic <base64("username:password")> where username is the combined key and password is blank
    req["Authorization"] = "Basic #{Base64.strict_encode64("#{key}:")}"
    req["Accept"] = "application/json"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
    puts res.code
    puts res.body
  end
end
