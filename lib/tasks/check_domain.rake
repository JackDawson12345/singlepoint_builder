# lib/tasks/list_package_types.rake
require "net/http"
require "json"
require "base64"

namespace :hosting do
  desc "List existing hosting packages to see package type IDs - Usage: rake hosting:list_types"
  task :list_types => :environment do
    key = Rails.application.credentials.dig(:twenty_i, :general_key) ||
          ENV["TWENTYI_GENERAL_KEY"]

    unless key
      abort "Error: TWENTYI_COMBINED_KEY environment variable not set"
    end

    uri = URI("https://api.20i.com/package")
    req = Net::HTTP::Get.new(uri)
    # Basic <base64("username:password")> where username is the combined key and password is blank
    req["Authorization"] = "Basic #{Base64.strict_encode64("#{key}:")}"
    req["Accept"] = "application/json"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }

    puts "Status: #{res.code}"
    puts "Raw Response: #{res.body}"

    if res.code.to_i == 200
      packages = JSON.parse(res.body)

      if packages.empty?
        puts "\nNo existing packages found."
        puts "You need to create package types in your 20i control panel first."
        puts "Go to: https://my.20i.com/reseller/packageTypes"
      else
        puts "\nYour existing hosting packages and their types:"
        puts "-" * 80

        # Group by package type to show unique types
        types_seen = {}

        packages.each do |package|
          type_id = package['typeRef']
          type_name = package['packageTypeName']

          unless types_seen[type_id]
            types_seen[type_id] = type_name
            puts "📦 Package Type ID: #{type_id} - #{type_name}"
          end

          puts "   └─ Package: #{package['name']} (ID: #{package['id']})"
        end

        puts "-" * 80
        puts "\n💡 Use the 'Package Type ID' numbers when creating new packages"
        puts "   Example: rake hosting:add[newdomain.com,#{types_seen.keys.first}]"
      end
    elsif res.code.to_i == 401
      puts "❌ Authentication failed"
      puts "Check that your TWENTYI_COMBINED_KEY is correct"
      puts "Get it from: https://my.20i.com/reseller/api"
    else
      puts "❌ Failed to fetch packages"
      puts "HTTP #{res.code}: #{res.body}"
    end
  end
end