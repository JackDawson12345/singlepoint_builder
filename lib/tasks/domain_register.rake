# lib/tasks/domain_register.rake
require_relative "../twenty_i_client"

namespace :domain do
  desc "Show your 20i resellerId"
  task :reseller_id => :environment do
    client = TwentyIClient.new
    puts client.reseller_id
  rescue TwentyIClient::Error => e
    abort e.message
  end

  desc "Register a domain. Usage: rake domain:register[name,years,privacy]"
  task :register, [:name, :years, :privacy] => :environment do |_, args|
    name    = args[:name] or abort "Usage: rake domain:register[name,years,privacy]"
    years   = (args[:years] || 1).to_i
    privacy = ActiveModel::Type::Boolean.new.cast(args[:privacy])

    contact =
      begin
        if ENV["TWENTYI_CONTACT_JSON"].present?
          JSON.parse(ENV["TWENTYI_CONTACT_JSON"])
        elsif ENV["TWENTYI_CONTACT_YAML"].present?
          require "yaml"
          YAML.load_file(ENV["TWENTYI_CONTACT_YAML"])
        else
          {
            "organisation" => "Unitel Direct Limited",
            "name" => "Unitel Direct Limited",
            "address" => "Unitel Direct LTD, 2nd Floor",
            "city" => "Cavendish House",
            "sp" => "Princes Wharf",
            "pc" => "TS17 6QY",
            "cc" => "GB",
            "telephone" => "+44.3301247118",
            "email" => "support@uniteldirect.co.uk",
            "extension" => {}
          }
        end
      rescue => e
        abort "Failed to load contact: #{e.message}"
      end

    nameservers = if ENV["TWENTYI_NAMESERVERS"].present?
                    # Comma separated: "ns1.example.com,ns2.example.com"
                    ENV["TWENTYI_NAMESERVERS"].split(",").map(&:strip)
                  else
                    nil # defaults to 20i nameservers
                  end

    payload = {
      "name" => name,
      "years" => years,
      "caRegistryAgreement" => true,
      "contact" => contact,
      "privacyService" => privacy
    }
    payload["nameservers"] = nameservers if nameservers

    # Optional extras through env if you need them
    payload["stackUser"] = ENV["TWENTYI_STACK_USER"] if ENV["TWENTYI_STACK_USER"].present?
    payload["limits"] = JSON.parse(ENV["TWENTYI_LIMITS"]) if ENV["TWENTYI_LIMITS"].present?
    payload["otherContacts"] = JSON.parse(ENV["TWENTYI_OTHER_CONTACTS"]) if ENV["TWENTYI_OTHER_CONTACTS"].present?

    client = TwentyIClient.new
    result = client.register_domain!(payload)

    puts "Result:"
    puts JSON.pretty_generate(result)
  rescue TwentyIClient::Error => e
    warn e.message
    exit 1
  end
end
