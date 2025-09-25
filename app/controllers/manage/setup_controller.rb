require "net/http"
require "json"
require "uri"
require "base64"

class Manage::SetupController < Manage::BaseController

  skip_before_action :has_website
  def index
    @user = current_user
    @themes = Theme.all
  end

  def search_domain
    query = params[:name]&.strip

    if query.blank?
      render json: { error: "Please enter a domain name" }, status: 400
      return
    end

    begin
      domains = search_available_domains(query)
      render json: { domains: domains, debug_info: "Search completed successfully" }
    rescue => e
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

  # Add this action to handle payment processing
  def create_payment_intent

    user_setup = current_user.user_setup
    payment_summary = user_setup.payment_summary

    begin
      # Create the payment intent with Stripe
      intent = Stripe::PaymentIntent.create({
                                              amount: payment_summary[:payment_amount_pence],
                                              currency: 'gbp',
                                              metadata: {
                                                user_id: current_user.id,
                                                user_email: current_user.email,
                                                package_type: user_setup.package_type,
                                                support_option: user_setup.support_option,
                                                base_price_pounds: payment_summary[:base_price],
                                                payment_type: payment_summary[:payment_type],
                                                is_deposit: payment_summary[:is_deposit],
                                                domain_name: user_setup.domain_name
                                              }
                                            })

      # Store the payment intent ID in the user setup
      user_setup.update(
        stripe_payment_intent_id: intent.id,
        payment_status: 'pending'
      )

      render json: {
        client_secret: intent.client_secret,
        payment_details: payment_summary
      }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue => e
      render json: { error: 'Something went wrong. Please try again.' }, status: :internal_server_error
    end
  end

  # Updated action to handle successful payments and domain purchase
  def confirm_payment
    payment_intent_id = params[:payment_intent_id]

    begin
      # Retrieve the payment intent from Stripe
      intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

      if intent.status == 'succeeded'
        user_setup = current_user.user_setup

        # Update payment status first
        user_setup.update!(
          payment_status: 'completed',
          paid_at: Time.current
        )

        # Now attempt to purchase the domain
        domain_purchase_result = purchase_domain_for_user(user_setup)

        if domain_purchase_result[:success]

          # Update user setup with domain purchase details
          user_setup.update!(
            domain_purchased: true,
            domain_purchase_details: domain_purchase_result[:details]
          )

          notify_all_admins("A new purchase has been made by #{current_user.email} for a #{current_user.user_setup.package_type} website. Support Option #{current_user.user_setup.support_option}", "Purchase Of A New Website")

          render json: {
            success: true,
            message: 'Payment successful and domain purchased!',
            domain_purchased: true,
            domain_details: domain_purchase_result[:details],
            redirect_url: manage_setup_path
          }
        else

          # Payment succeeded but domain purchase failed
          # Store the error for later retry
          user_setup.update!(
            domain_purchased: false,
            domain_purchase_error: domain_purchase_result[:error]
          )

          render json: {
            success: true,
            message: 'Payment successful! Domain purchase encountered an issue - we will retry shortly.',
            domain_purchased: false,
            domain_error: domain_purchase_result[:error],
            redirect_url: manage_setup_path
          }
        end
      else
        render json: {
          success: false,
          message: 'Payment was not successful. Please try again.'
        }
      end
    rescue Stripe::StripeError => e
      render json: {
        success: false,
        message: 'Unable to confirm payment. Please contact support.'
      }
    rescue => e
      render json: {
        success: false,
        message: 'An error occurred during confirmation. Please contact support.'
      }
    end
  end

  def set_website_theme
    theme = Theme.find(params[:theme_id])

    # Create updated pages with new theme_page_ids and component_page_ids
    updated_pages = theme.pages.deep_dup

    if updated_pages["theme_pages"]
      updated_pages["theme_pages"].each do |page_key, page_data|
        # Update theme_page_id
        if page_data["theme_page_id"]
          page_data["theme_page_id"] = SecureRandom.uuid
        end

        # Update component_page_ids
        if page_data["components"]&.is_a?(Array)
          page_data["components"].each do |component|
            if component["component_page_id"]
              component["component_page_id"] = SecureRandom.uuid
            end
          end
        end
      end
    end

    @website = Website.create(
      user_id: current_user.id,
      theme_id: theme.id,
      name: 'My Website',
      description: 'Description Of My Website',
      pages: updated_pages,
      domain_name: current_user.user_setup.domain_name,
      settings: theme.settings,

    )

    @invoice_template = InvoiceTemplate.create(
      website_id: @website.id
    )

    @user_setup = current_user.user_setup.update(theme_id: theme.id)

    notify_all_admins("A new website has been set up for #{current_user.email} with the id of #{current_user.website.id}", "New Website Setup Successfully")
    redirect_to manage_website_website_path
  end

  # New action to manually retry domain purchase (optional)
  def retry_domain_purchase
    user_setup = current_user.user_setup

    unless user_setup.payment_status == 'completed'
      redirect_to manage_setup_path, alert: "Payment must be completed before purchasing domain"
      return
    end

    if user_setup.domain_purchased?
      redirect_to manage_setup_path, notice: "Domain has already been purchased"
      return
    end

    result = purchase_domain_for_user(user_setup)

    if result[:success]
      user_setup.update!(
        domain_purchased: true,
        domain_purchase_details: result[:details],
        domain_purchase_error: nil
      )
      redirect_to manage_setup_path, notice: "Domain purchased successfully!"
    else
      user_setup.update!(domain_purchase_error: result[:error])
      redirect_to manage_setup_path, alert: "Domain purchase failed: #{result[:error]}"
    end
  end

  private

  def calculate_payment_amount
    user_setup = current_user.user_setup

    # Base prices based on package type
    base_price = case user_setup.package_type&.downcase
                 when 'bespoke'
                   500.00
                 when 'e-commerce'
                   1000.00
                 else
                   200.00 # Default fallback price
                 end

    # Determine if it's full payment or deposit
    is_full_payment = user_setup.support_option == 'Do It Myself'

    if is_full_payment
      # Take full payment
      amount = base_price
      amount_type = 'full_payment'
      is_deposit = false
    else
      # Take 20% deposit
      amount = (base_price * 0.20).round(2)
      amount_type = 'deposit'
      is_deposit = true
    end

    # Convert to pence for Stripe (Stripe works in smallest currency unit)
    amount_pence = (amount * 100).to_i

    {
      total_price: base_price,
      amount: amount,
      amount_pence: amount_pence,
      amount_type: amount_type,
      is_deposit: is_deposit,
      deposit_percentage: is_deposit ? 20 : nil,
      remaining_amount: is_deposit ? (base_price - amount).round(2) : nil
    }
  end

  # Add this helper method to get payment details for the view
  def get_payment_details_for_user
    calculate_payment_amount
  end

  # New method to handle domain purchasing
  def purchase_domain_for_user(user_setup)

    unless user_setup.domain_name.present?
      return {
        success: false,
        error: "No domain name selected"
      }
    end

    begin
      # Load the TwentyIClient exactly like the rake task does
      require_relative Rails.root.join('lib', 'twenty_i_client')
      client = TwentyIClient.new

      # Use the exact same contact info as the rake task
      contact = {
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

      # Build payload exactly like the rake task
      payload = {
        "name" => user_setup.domain_name,
        "years" => 1,
        "caRegistryAgreement" => true,
        "contact" => contact,
        "privacyService" => false  # Changed from true to false
      }

      # Register the domain
      result = client.register_domain!(payload)

      {
        success: true,
        details: {
          domain: user_setup.domain_name,
          registered_at: Time.current,
          years: 1,
          privacy_enabled: false,  # Updated to reflect the actual setting
          api_response: result
        }
      }

    rescue TwentyIClient::Error => e

      # Handle specific error cases
      error_message = if e.message.include?("Payment required") || e.message.include?("402")
                        "Insufficient credit in reseller account. Please contact support to add credit for domain registration."
                      elsif e.message.include?("already registered") || e.message.include?("unavailable")
                        "Domain is no longer available for registration."
                      else
                        "Domain registration failed: #{e.message}"
                      end

      {
        success: false,
        error: error_message
      }
    rescue => e
      {
        success: false,
        error: "An unexpected error occurred during domain registration"
      }
    end
  end

  def search_available_domains(query)

    general_key = Rails.application.credentials.dig(:twenty_i, :general_key) ||
                  ENV["TWENTY_I_GENERAL_KEY"]

    if general_key.to_s.strip.empty?
      raise "Missing 20i general key. Please check credentials or TWENTYI_GENERAL_KEY environment variable."
    end

    bearer = Base64.strict_encode64(general_key.strip)
    encoded_query = URI.encode_www_form_component(query)
    uri = URI("https://api.20i.com/domain-search/#{encoded_query}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 20

    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{bearer}"
    req["Accept"] = "application/json"

    res = http.request(req)

    unless res.code.to_i.between?(200, 299)
      raise "API returned #{res.code}: #{res.body}"
    end

    begin
      response_data = JSON.parse(res.body)
    rescue JSON::ParserError => e
      raise "Invalid JSON response from API: #{e.message}"
    end

    # Process the response based on its structure
    domains = process_domain_response(response_data, query)

    domains
  end

  def stripe_publishable_key
    Rails.application.credentials.dig(:stripe, :publishable_key) || ENV['STRIPE_PUBLISHABLE_KEY']
  end

  def process_domain_response(response_data, base_query = nil)

    domains = []

    if response_data.is_a?(Hash)

      # Handle different possible response structures
      if response_data["domains"]
        domains = response_data["domains"].map { |domain| format_domain(domain, base_query) }.compact
      elsif response_data["results"]
        domains = response_data["results"].map { |domain| format_domain(domain, base_query) }.compact
      elsif response_data["header"] && response_data["header"]["names"]
        # Handle the specific structure we're seeing: {"header" => {"names" => ["domain.com"]}}
        domains = response_data["header"]["names"].map do |domain_name|
          {
            name: domain_name,
            available: true, # Assume available since it's in search results
            price: nil
          }
        end
      else
        # Try to extract domain names from any nested structure
        domains = extract_domain_names_from_response(response_data, base_query)
      end
    elsif response_data.is_a?(Array)
      domains = response_data.map { |domain| format_domain(domain, base_query) }.compact
    else
      domains = []
    end

    # Filter out any invalid domains (format_domain returns nil for invalid domains)
    valid_domains = domains.select { |d| d.present? && d[:name].present? && d[:name].is_a?(String) }

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
        return nil # Invalid domain string
      end
    when Hash
      # Handle header objects
      if domain["header"] && domain["header"]["names"]
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
      return nil
    end

    # Validate the domain name
    if formatted[:name].blank? || !formatted[:name].is_a?(String)
      return nil
    end

    formatted
  end

  def determine_domain_availability(domain_data)

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
      # Default to unavailable if we're not sure
      return false
    end
  end
end