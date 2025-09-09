# lib/tasks/domain_management.rake
require "net/http"
require "json"
require "base64"

namespace :domain do
  desc "Find domain for DNS management - Usage: rake domain:find name=example.co.uk"
  task :find => :environment do |_, args|
    domain_name = ENV['name']
    domain_name or abort "Usage: rake domain:find name=example.co.uk"

    api_key = Rails.application.credentials.dig(:twenty_i, :general_key) ||
              ENV["TWENTYI_GENERAL_KEY"] or abort "TWENTYI_GENERAL_API_KEY environment variable not set"

    puts "=== DOMAIN SEARCH ==="
    puts "Searching for domain: #{domain_name}"
    puts "===================="

    found_domain = find_domain_by_name(domain_name, api_key)

    if found_domain
      display_domain_info(found_domain)
    else
      puts "Domain '#{domain_name}' not found in your 20i account."
      puts "Make sure the domain is registered through 20i or transferred to your account."
    end
  end

  desc "Get DNS records for domain - Usage: rake domain:dns name=example.co.uk"
  task :dns => :environment do |_, args|
    domain_name = ENV['name']
    domain_name or abort "Usage: rake domain:dns name=example.co.uk"

    api_key = ENV["TWENTYI_GENERAL_API_KEY"] or abort "TWENTYI_GENERAL_API_KEY environment variable not set"

    puts "=== DNS RECORDS ==="
    puts "Getting DNS for: #{domain_name}"
    puts "=================="

    # First find the domain to get its ID
    domain = find_domain_by_name(domain_name, api_key)

    unless domain
      puts "Domain '#{domain_name}' not found. Use 'rake domain:find name=#{domain_name}' first."
      return
    end

    dns_records = get_dns_records(domain['id'], api_key)

    if dns_records
      display_dns_records(domain_name, dns_records)
    else
      puts "Could not retrieve DNS records for #{domain_name}"
    end
  end

  desc "Get nameservers for domain - Usage: rake domain:nameservers name=example.co.uk"
  task :nameservers => :environment do |_, args|
    domain_name = ENV['name']
    domain_name or abort "Usage: rake domain:nameservers name=example.co.uk"

    api_key = ENV["TWENTYI_GENERAL_API_KEY"] or abort "TWENTYI_GENERAL_API_KEY environment variable not set"

    puts "=== NAMESERVERS ==="
    puts "Getting nameservers for: #{domain_name}"
    puts "=================="

    # First find the domain to get its ID
    domain = find_domain_by_name(domain_name, api_key)

    unless domain
      puts "Domain '#{domain_name}' not found. Use 'rake domain:find name=#{domain_name}' first."
      return
    end

    nameservers = get_nameservers(domain['id'], api_key)

    if nameservers
      display_nameservers(domain_name, nameservers)
    else
      puts "Could not retrieve nameservers for #{domain_name}"
    end
  end

  desc "Set nameservers for domain - Usage: rake domain:set_nameservers name=example.co.uk ns1=ns1.example.com ns2=ns2.example.com"
  task :set_nameservers => :environment do |_, args|
    domain_name = ENV['name']
    ns1 = ENV['ns1']
    ns2 = ENV['ns2']
    ns3 = ENV['ns3']  # Optional
    ns4 = ENV['ns4']  # Optional

    domain_name or abort "Usage: rake domain:set_nameservers name=example.co.uk ns1=ns1.example.com ns2=ns2.example.com [ns3=ns3.example.com] [ns4=ns4.example.com]"
    ns1 or abort "ns1 is required"
    ns2 or abort "ns2 is required"

    api_key = ENV["TWENTYI_GENERAL_API_KEY"] or abort "TWENTYI_GENERAL_API_KEY environment variable not set"

    puts "=== SET NAMESERVERS ==="
    puts "Setting nameservers for: #{domain_name}"
    puts "======================"

    # Build nameservers array
    new_nameservers = [ns1, ns2]
    new_nameservers << ns3 if ns3
    new_nameservers << ns4 if ns4

    puts "New nameservers: #{new_nameservers.join(', ')}"

    # First find the domain to get its ID
    domain = find_domain_by_name(domain_name, api_key)

    unless domain
      puts "Domain '#{domain_name}' not found. Use 'rake domain:find name=#{domain_name}' first."
      return
    end

    # Get current nameservers first (required by API)
    current_nameservers = get_nameservers(domain['id'], api_key)

    unless current_nameservers
      puts "Could not retrieve current nameservers. Cannot proceed."
      return
    end

    puts "Current nameservers: #{current_nameservers['result'].join(', ')}"

    # Set the new nameservers
    result = set_nameservers(domain['id'], new_nameservers, current_nameservers['result'], api_key)

    if result
      puts "✅ Nameservers updated successfully!"
      puts "New nameservers: #{new_nameservers.join(', ')}"
      puts "Note: DNS changes may take up to 24-48 hours to propagate globally."
    else
      puts "❌ Failed to update nameservers."
    end
  end

  desc "List all domains in account - Usage: rake domain:list"
  task :list => :environment do
    api_key = ENV["TWENTYI_GENERAL_API_KEY"] or abort "TWENTYI_GENERAL_API_KEY environment variable not set"

    puts "=== ALL DOMAINS ==="
    puts "Getting all domains..."
    puts "=================="

    domains = get_all_domains_paginated(api_key)

    if domains && domains.any?
      puts "Found #{domains.length} domains:"
      puts ""
      domains.each_with_index do |domain, index|
        puts "#{index + 1}. #{domain['name']} (ID: #{domain['id']})"
        puts "   Created: #{domain['created'] || 'N/A'}"
        puts "   Status: #{domain['status'] || 'N/A'}"
        puts "   Expires: #{domain['expires'] || 'N/A'}" if domain['expires']
        puts ""
      end
    else
      puts "No domains found in your account."
    end
  end

  private

  def find_domain_by_name(domain_name, api_key)
    puts "Searching for domain: #{domain_name}..."

    # Search through domains with pagination
    page = 0
    limit = 200

    loop do
      puts "Searching page #{page + 1}..." if page > 0

      uri = URI("https://api.20i.com/domain?limit=#{limit}&offset=#{page * limit}")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{Base64.strict_encode64(api_key)}"
      req["Accept"] = "application/json"
      req["User-Agent"] = "Rails-20i-Client/1.0"

      res = make_http_request(uri, req)
      break unless res.code == "200"

      domains = JSON.parse(res.body)
      break if domains.empty?

      # Look for exact match
      found = domains.find { |domain| domain["name"] == domain_name }
      return found if found

      break if domains.length < limit # Last page
      page += 1

      # Safety break - adjust if you have more than 10k domains
      break if page > 200
    end

    nil
  end

  def get_all_domains_paginated(api_key, max_pages: 100)
    domains = []
    page = 0
    limit = 100

    loop do
      uri = URI("https://api.20i.com/domain?limit=#{limit}&offset=#{page * limit}")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{Base64.strict_encode64(api_key)}"
      req["Accept"] = "application/json"
      req["User-Agent"] = "Rails-20i-Client/1.0"

      res = make_http_request(uri, req)
      break unless res.code == "200"

      batch = JSON.parse(res.body)
      break if batch.empty?

      domains.concat(batch)

      break if batch.length < limit # Last page
      page += 1
      break if page > max_pages # Safety limit
    end

    domains
  end

  def get_dns_records(domain_id, api_key)
    uri = URI("https://api.20i.com/domain/#{domain_id}/dns")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{Base64.strict_encode64(api_key)}"
    req["Accept"] = "application/json"
    req["User-Agent"] = "Rails-20i-Client/1.0"

    res = make_http_request(uri, req)
    return JSON.parse(res.body) if res.code == "200"

    puts "Error getting DNS records: #{res.code}"
    puts res.body
    nil
  end

  def get_nameservers(domain_id, api_key)
    uri = URI("https://api.20i.com/domain/#{domain_id}/nameservers")
    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{Base64.strict_encode64(api_key)}"
    req["Accept"] = "application/json"
    req["User-Agent"] = "Rails-20i-Client/1.0"

    res = make_http_request(uri, req)
    return JSON.parse(res.body) if res.code == "200"

    puts "Error getting nameservers: #{res.code}"
    puts res.body
    nil
  end

  def set_nameservers(domain_id, new_ns, old_ns, api_key)
    uri = URI("https://api.20i.com/domain/#{domain_id}/nameservers")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{Base64.strict_encode64(api_key)}"
    req["Accept"] = "application/json"
    req["Content-Type"] = "application/json"
    req["User-Agent"] = "Rails-20i-Client/1.0"

    payload = {
      "ns" => new_ns,
      "old-ns" => old_ns
    }

    req.body = payload.to_json

    res = make_http_request(uri, req)

    if res.code == "200"
      return JSON.parse(res.body)
    else
      puts "Error setting nameservers: #{res.code}"
      puts res.body
      return nil
    end
  end

  def make_http_request(uri, req)
    Net::HTTP.start(uri.hostname, uri.port,
                    use_ssl: true,
                    read_timeout: 30,
                    open_timeout: 10,
                    keep_alive_timeout: 30) { |http| http.request(req) }
  end

  def display_domain_info(domain)
    puts "✅ Domain Found!"
    puts "=" * 40
    puts "Domain Name: #{domain['name']}"
    puts "Domain ID: #{domain['id']}"
    puts "Status: #{domain['status'] || 'N/A'}"
    puts "Created: #{domain['created'] || 'N/A'}"
    puts "Expires: #{domain['expires'] || 'N/A'}" if domain['expires']
    puts "Registrar: #{domain['registrar'] || 'N/A'}" if domain['registrar']
    puts ""
    puts "You can now manage DNS for this domain using:"
    puts "  rake domain:dns name=#{domain['name']}"
    puts "  rake domain:nameservers name=#{domain['name']}"
  end

  def display_dns_records(domain_name, dns_data)
    puts "DNS Records for #{domain_name}:"
    puts "=" * 50

    if dns_data.is_a?(Hash)
      dns_data.each do |record_type, records|
        next unless records.is_a?(Array) && records.any?

        puts "\n#{record_type.upcase} Records:"
        records.each_with_index do |record, index|
          puts "  #{index + 1}. #{record}"
        end
      end
    else
      puts "DNS data format not recognized:"
      puts JSON.pretty_generate(dns_data)
    end

    puts "\nTo modify DNS records, you may need to use the 20i control panel"
    puts "or contact 20i support for specific API endpoints."
  end

  def display_nameservers(domain_name, ns_data)
    puts "Nameservers for #{domain_name}:"
    puts "=" * 50

    if ns_data && ns_data['result']
      ns_data['result'].each_with_index do |ns, index|
        puts "  #{index + 1}. #{ns}"
      end
    else
      puts "No nameserver data found or unexpected format:"
      puts JSON.pretty_generate(ns_data)
    end

    puts "\nTo change nameservers, use:"
    puts "rake domain:set_nameservers name=#{domain_name} ns1=ns1.example.com ns2=ns2.example.com"
  end
end