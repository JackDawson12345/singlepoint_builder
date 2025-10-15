# lib/tasks/streamline_icons.rake
namespace :streamline do
  desc "Debug: Search and show full response structure"
  task :debug_search, [:query] => :environment do |t, args|
    require 'httparty'

    query = args[:query] || 'home'

    puts "Searching for: #{query}"
    puts "="*50

    response = HTTParty.get(
      'https://public-api.streamlinehq.com/v1/search/global',
      query: {
        productType: 'icons',
        query: query
      },
      headers: {
        'accept' => 'application/json',
        'x-api-key' => 'Re7yYIvBhU1MPYIf.e0152318cbdc5ebcc21d09dbc0d5d49d'
      }
    )

    if response.success?
      puts "Status: #{response.code}"
      puts "\nFull Response:"
      puts JSON.pretty_generate(response.parsed_response)

      # Try to identify the icon ID field
      if response.parsed_response['results']&.any?
        first_icon = response.parsed_response['results'].first
        puts "\n" + "="*50
        puts "First Icon Fields:"
        first_icon.each do |key, value|
          puts "  #{key}: #{value}"
        end
      end
    else
      puts "Error: #{response.code}"
      puts response.body
    end
  end

  desc "Get SVG with better error handling"
  task :get_svg, [:icon_hash] => :environment do |t, args|
    require 'httparty'

    icon_hash = args[:icon_hash]

    if icon_hash.blank?
      puts "Error: Please provide an icon hash"
      puts "Usage: rake streamline:get_svg[ICON_HASH]"
      exit
    end

    # Try different endpoint formats
    endpoints = [
      "https://public-api.streamlinehq.com/icons/#{icon_hash}/download/svg",
      "https://public-api.streamlinehq.com/v1/icons/#{icon_hash}/svg",
      "https://public-api.streamlinehq.com/v1/icons/#{icon_hash}/download",
    ]

    endpoints.each_with_index do |endpoint, index|
      puts "\nTrying endpoint #{index + 1}: #{endpoint}"

      svg_response = HTTParty.get(
        endpoint,
        query: { responsive: true },
        headers: {
          'accept' => 'image/svg+xml',
          'x-api-key' => 'Re7yYIvBhU1MPYIf.e0152318cbdc5ebcc21d09dbc0d5d49d'
        }
      )

      puts "Status: #{svg_response.code}"

      if svg_response.success?
        puts "\n✓ Success! SVG Code:"
        puts svg_response.body
        break
      else
        puts "✗ Failed"
        puts "Response: #{svg_response.body[0..200]}" if svg_response.body
      end
    end
  end

  desc "Search and try to get SVG with full debugging"
  task :full_debug, [:query] => :environment do |t, args|
    require 'httparty'

    query = args[:query] || 'home'

    puts "STEP 1: Searching for '#{query}'"
    puts "="*60

    search_response = HTTParty.get(
      'https://public-api.streamlinehq.com/v1/search/global',
      query: {
        productType: 'icons',
        query: query
      },
      headers: {
        'accept' => 'application/json',
        'x-api-key' => 'Re7yYIvBhU1MPYIf.e0152318cbdc5ebcc21d09dbc0d5d49d'
      }
    )

    unless search_response.success?
      puts "Search failed: #{search_response.code}"
      puts search_response.body
      exit
    end

    results = search_response.parsed_response

    if results['results'].blank?
      puts "No results found"
      puts "\nFull response:"
      puts JSON.pretty_generate(results)
      exit
    end

    puts "Found #{results['results'].length} results"
    puts "\nFirst result structure:"
    first_icon = results['results'].first
    puts JSON.pretty_generate(first_icon)

    # Try to find the icon identifier
    possible_id_fields = ['_id', 'id', 'hash', 'uuid', 'iconId', 'assetId']
    icon_id = nil
    id_field = nil

    possible_id_fields.each do |field|
      if first_icon[field]
        icon_id = first_icon[field]
        id_field = field
        break
      end
    end

    if icon_id.nil?
      puts "\n✗ Could not find icon ID in response"
      puts "Available fields: #{first_icon.keys.join(', ')}"
      exit
    end

    puts "\n" + "="*60
    puts "STEP 2: Trying to fetch SVG"
    puts "Using field '#{id_field}': #{icon_id}"
    puts "="*60

    # Try multiple endpoint patterns
    endpoint_patterns = [
      "https://public-api.streamlinehq.com/icons/#{icon_id}/download/svg",
      "https://public-api.streamlinehq.com/v1/icons/#{icon_id}/svg",
      "https://public-api.streamlinehq.com/v1/icons/#{icon_id}/download",
      "https://public-api.streamlinehq.com/assets/#{icon_id}/svg",
      "https://public-api.streamlinehq.com/v1/assets/#{icon_id}/download/svg",
    ]

    endpoint_patterns.each_with_index do |endpoint, index|
      puts "\n#{index + 1}. Trying: #{endpoint}"

      svg_response = HTTParty.get(
        endpoint,
        query: { responsive: true },
        headers: {
          'accept' => 'image/svg+xml',
          'x-api-key' => 'Re7yYIvBhU1MPYIf.e0152318cbdc5ebcc21d09dbc0d5d49d'
        }
      )

      puts "Status: #{svg_response.code}"

      if svg_response.success?
        puts "   ✓ SUCCESS!"
        puts "\nSVG Code:"
        puts svg_response.body
        puts "\n" + "="*60
        puts "Working endpoint: #{endpoint}"
        break
      else
        puts "   ✗ Failed: #{svg_response.message}"
        if svg_response.body && svg_response.body.length < 500
          puts "   Response: #{svg_response.body}"
        end
      end
    end
  end
end