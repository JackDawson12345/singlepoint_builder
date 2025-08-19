require "net/http"
require "json"
require "uri"
require "base64"

class Manage::SetupController < Manage::BaseController

  skip_before_action :has_website
  def index
    @user = current_user
  end

  def search_domain
    query = params[:name]&.strip

    Rails.logger.info "Domain search initiated for query: '#{query}'"

    if query.blank?
      Rails.logger.warn "Domain search failed: empty query"
      render json: { error: "Please enter a domain name" }, status: 400
      return
    end

    begin
      domains = search_available_domains(query)
      Rails.logger.info "Domain search completed successfully. Found #{domains.length} domains"
      render json: { domains: domains, debug_info: "Search completed successfully" }
    rescue => e
      Rails.logger.error "Domain search failed with error: #{e.class.name}: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join(', ')}"

      # Return detailed error for debugging
      render json: {
        error: "Search failed: #{e.message}",
        debug_info: {
          error_class: e.class.name,
          error_message: e.message,
          query: query
        }
      }, status: 500
    end
  end

  def select_domain
    domain_name = params[:domain_name]&.strip

    if domain_name.blank?
      redirect_to manage_setup_path, alert: "Please select a domain"
      return
    end

    if current_user.user_setup.update(domain_name: domain_name)
      redirect_to manage_setup_path, notice: "Domain selected successfully!"
    else
      redirect_to manage_setup_path, alert: "Failed to save domain selection"
    end
  end

  def package
    package_type = params[:package_type]

    if package_type.blank?
      redirect_to manage_setup_path, alert: "Please select a package"
      return
    end

    if current_user.user_setup.update(package_type: package_type)
      redirect_to manage_setup_path, notice: "Package selected successfully!"
    else
      redirect_to manage_setup_path, alert: "Failed to save Package selection"
    end
  end

  def support
    support_option = params[:support_option]

    if support_option.blank?
      redirect_to manage_setup_path, alert: "Please select a support option"
      return
    end

    if current_user.user_setup.update(support_option: support_option)
      redirect_to manage_setup_path, notice: "Support option selected successfully!"
    else
      redirect_to manage_setup_path, alert: "Failed to save support option selection"
    end
  end

  private

  def search_available_domains(query)
    Rails.logger.info "Starting domain search for: #{query}"

    general_key = Rails.application.credentials.dig(:twenty_i, :general_key) ||
                  ENV["TWENTYI_GENERAL_KEY"]

    Rails.logger.info "API key present: #{general_key.present?}"
    Rails.logger.info "API key length: #{general_key&.length || 0}"

    if general_key.to_s.strip.empty?
      Rails.logger.error "Missing 20i general key - no key found in credentials or ENV"
      raise "Missing 20i general key. Please check credentials or TWENTYI_GENERAL_KEY environment variable."
    end

    bearer = Base64.strict_encode64(general_key.strip)
    encoded_query = URI.encode_www_form_component(query)
    uri = URI("https://api.20i.com/domain-search/#{encoded_query}")

    Rails.logger.info "Making request to: #{uri}"
    Rails.logger.info "Bearer token (first 10 chars): #{bearer[0..9]}..."

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 20

    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{bearer}"
    req["Accept"] = "application/json"

    Rails.logger.info "Sending HTTP request..."

    res = http.request(req)

    Rails.logger.info "HTTP Response code: #{res.code}"
    Rails.logger.info "HTTP Response headers: #{res.to_hash}"
    Rails.logger.info "HTTP Response body (first 500 chars): #{res.body[0..499]}"

    unless res.code.to_i.between?(200, 299)
      Rails.logger.error "API returned non-success status: #{res.code}"
      raise "API returned #{res.code}: #{res.body}"
    end

    begin
      response_data = JSON.parse(res.body)
      Rails.logger.info "Parsed JSON response: #{response_data.inspect}"
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse JSON response: #{e.message}"
      Rails.logger.error "Raw response body: #{res.body}"
      raise "Invalid JSON response from API: #{e.message}"
    end

    # Process the response based on its structure
    domains = process_domain_response(response_data, query)
    Rails.logger.info "Processed #{domains.length} domains: #{domains.inspect}"

    domains
  end

  # Add this action to handle payment processing
  def create_payment_intent
    begin
      # Create the payment intent with Stripe
      intent = Stripe::PaymentIntent.create({
                                              amount: 20000, # £200.00 in pence
                                              currency: 'gbp',
                                              metadata: {
                                                user_id: current_user.id,
                                                user_email: current_user.email
                                              }
                                            })

      # Store the payment intent ID in the user setup
      current_user.user_setup.update(
        stripe_payment_intent_id: intent.id,
        payment_status: 'pending'
      )

      render json: { client_secret: intent.client_secret }
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe error: #{e.message}"
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error "Payment intent creation error: #{e.message}"
      render json: { error: 'Something went wrong. Please try again.' }, status: :internal_server_error
    end
  end

  # Add this action to handle successful payments
  def confirm_payment
    payment_intent_id = params[:payment_intent_id]

    begin
      # Retrieve the payment intent from Stripe
      intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

      if intent.status == 'succeeded'
        # Update the user setup with payment confirmation
        user_setup = current_user.user_setup
        user_setup.update!(
          payment_status: 'completed',
          paid_at: Time.current
        )

        render json: {
          success: true,
          message: 'Payment successful!',
          redirect_url: manage_setup_path
        }
      else
        render json: {
          success: false,
          message: 'Payment was not successful. Please try again.'
        }
      end
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe confirmation error: #{e.message}"
      render json: {
        success: false,
        message: 'Unable to confirm payment. Please contact support.'
      }
    end
  end

  private

  def stripe_publishable_key
    Rails.application.credentials.dig(:stripe, :publishable_key) || ENV['STRIPE_PUBLISHABLE_KEY']
  end

  def process_domain_response(response_data, base_query = nil)
    Rails.logger.info "Processing response data type: #{response_data.class.name}"
    Rails.logger.info "Full response data: #{response_data.inspect}"
    Rails.logger.info "Base query: #{base_query}"

    domains = []

    if response_data.is_a?(Hash)
      Rails.logger.info "Response is hash with keys: #{response_data.keys}"

      # Handle different possible response structures
      if response_data["domains"]
        Rails.logger.info "Found 'domains' key with #{response_data['domains'].length} items"
        domains = response_data["domains"].map { |domain| format_domain(domain, base_query) }.compact
      elsif response_data["results"]
        Rails.logger.info "Found 'results' key with #{response_data['results'].length} items"
        domains = response_data["results"].map { |domain| format_domain(domain, base_query) }.compact
      elsif response_data["header"] && response_data["header"]["names"]
        # Handle the specific structure we're seeing: {"header" => {"names" => ["domain.com"]}}
        Rails.logger.info "Found header with names structure"
        domains = response_data["header"]["names"].map do |domain_name|
          {
            name: domain_name,
            available: true, # Assume available since it's in search results
            price: nil
          }
        end
      else
        # Try to extract domain names from any nested structure
        Rails.logger.info "Searching for domain names in response structure"
        domains = extract_domain_names_from_response(response_data, base_query)
      end
    elsif response_data.is_a?(Array)
      Rails.logger.info "Response is array with #{response_data.length} items"
      domains = response_data.map { |domain| format_domain(domain, base_query) }.compact
    else
      Rails.logger.warn "Unexpected response format: #{response_data.class.name}"
      domains = []
    end

    # Filter out any invalid domains (format_domain returns nil for invalid domains)
    valid_domains = domains.select { |d| d.present? && d[:name].present? && d[:name].is_a?(String) }
    Rails.logger.info "Filtered to #{valid_domains.length} valid domains: #{valid_domains.inspect}"

    valid_domains
  end

  def extract_domain_names_from_response(data, base_query = nil, domains = [])
    case data
    when Hash
      data.each do |key, value|
        if key == "names" && value.is_a?(Array)
          # Found a "names" array, extract domain names
          value.each do |name|
            if name.is_a?(String) && name.include?(".")
              domains << {
                name: name,
                available: true,
                price: nil
              }
            end
          end
        else
          # Recursively search nested hashes
          extract_domain_names_from_response(value, base_query, domains)
        end
      end
    when Array
      data.each { |item| extract_domain_names_from_response(item, base_query, domains) }
    when String
      # Check if it's a domain extension (starts with .) and we have a base query
      if data.start_with?(".") && base_query.present?
        full_domain = "#{base_query}#{data}"
        domains << {
          name: full_domain,
          available: true,
          price: nil
        }
      elsif data.include?(".") && !data.include?(" ")
        # If it's a full domain, add it
        domains << {
          name: data,
          available: true,
          price: nil
        }
      end
    end

    domains
  end

  def format_domain(domain, base_query = nil)
    Rails.logger.debug "Formatting domain: #{domain.inspect} with base query: #{base_query}"

    # Handle different input types
    case domain
    when String
      # Check if it's a domain extension
      if domain.start_with?(".") && base_query.present?
        full_domain = "#{base_query}#{domain}"
        formatted = {
          name: full_domain,
          available: true, # Extensions from search are typically available
          price: nil
        }
      elsif domain.include?(".") && !domain.include?(" ")
        formatted = {
          name: domain,
          available: true,
          price: nil
        }
      else
        Rails.logger.warn "Invalid domain string: #{domain}"
        return nil # Invalid domain string
      end
    when Hash
      # Handle header objects
      if domain["header"] && domain["header"]["names"]
        Rails.logger.debug "Skipping header object"
        return nil
      end

      domain_name = domain["domain"] || domain["name"] || domain["domain_name"]

      # If the domain name is an extension and we have a base query, combine them
      if domain_name&.start_with?(".") && base_query.present?
        domain_name = "#{base_query}#{domain_name}"
      end

      # Determine availability based on the 'can' field and other indicators
      available = determine_domain_availability(domain)

      formatted = {
        name: domain_name,
        available: available,
        price: domain["price"] || domain["cost"] || domain["annual_price"] || nil
      }
    else
      Rails.logger.warn "Unknown domain format: #{domain.class.name}"
      return nil
    end

    # Validate the domain name
    if formatted[:name].blank? || !formatted[:name].is_a?(String)
      Rails.logger.warn "Invalid domain name: #{formatted[:name]}"
      return nil
    end

    Rails.logger.debug "Formatted domain: #{formatted.inspect}"
    formatted
  end

  def determine_domain_availability(domain_data)
    Rails.logger.debug "Determining availability for: #{domain_data.inspect}"

    # Check explicit availability field first
    if domain_data.key?("available")
      return domain_data["available"]
    end

    # Check status field
    if domain_data["status"] == "available"
      return true
    elsif domain_data["status"] == "unavailable" || domain_data["status"] == "taken"
      return false
    end

    # Check the 'can' field - this seems to indicate what you can do with the domain
    can_value = domain_data["can"]
    case can_value
    when "register"
      # Can register = available for registration
      return true
    when "transfer-prepare", "transfer-fix", "transfer"
      # Can transfer = already registered, not available for new registration
      return false
    when nil, ""
      # No 'can' field might mean it's available for registration
      return true
    else
      Rails.logger.warn "Unknown 'can' value: #{can_value}"
      # Default to unavailable if we're not sure
      return false
    end
  end
end