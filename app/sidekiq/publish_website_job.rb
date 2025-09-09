class PublishWebsiteJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.find(user_id)
    website = user.website

    return unless website&.domain_name

    Rails.logger.info "Publishing website for user #{user_id}: #{website.domain_name}"

    begin
      # Initialize Heroku API
      require 'resolv'

      api_token = Rails.application.credentials.heroku[:api_token] || ENV['HEROKU_API_TOKEN']
      app_name = Rails.application.credentials.heroku[:app_name] || ENV['HEROKU_APP_NAME']

      raise "Missing Heroku API token" unless api_token
      raise "Missing Heroku app name" unless app_name

      heroku = PlatformAPI.connect_oauth(api_token)

      # Check if domains already exist
      existing_domains = heroku.domain.list(app_name).map { |d| d['hostname'] }

      domain_hostname = website.domain_name
      www_hostname = "www.#{website.domain_name}"

      # Create root domain if it doesn't exist
      domain = nil
      if existing_domains.include?(domain_hostname)
        Rails.logger.info "Domain #{domain_hostname} already exists"
        domain = heroku.domain.list(app_name).find { |d| d['hostname'] == domain_hostname }
      else
        Rails.logger.info "Creating domain: #{domain_hostname}"
        domain = heroku.domain.create(app_name, {
          hostname: domain_hostname,
          sni_endpoint: nil
        })
      end

      # Create www domain if it doesn't exist
      root_domain = nil
      if existing_domains.include?(www_hostname)
        Rails.logger.info "Domain #{www_hostname} already exists"
        root_domain = heroku.domain.list(app_name).find { |d| d['hostname'] == www_hostname }
      else
        Rails.logger.info "Creating domain: #{www_hostname}"
        root_domain = heroku.domain.create(app_name, {
          hostname: www_hostname,
          sni_endpoint: nil
        })
      end

      Rails.logger.info "Domain DNS target: #{domain['cname']}"
      Rails.logger.info "Root domain DNS target: #{root_domain['cname']}"

      # Wait a bit for DNS targets to be ready
      sleep(5)

      # Resolve DNS with retry logic
      domain_ips = resolve_dns_with_retry(domain['cname'])
      www_ips = resolve_dns_with_retry(root_domain['cname'])

      # Store DNS information in user_setup with separate entries for each domain
      # Get existing DNS configurations or initialize empty hash
      current_dns_configs = user.user_setup&.dns_configurations || {}

      # Create configuration for root domain
      root_dns_config = {
        hostname: domain_hostname,
        type: 'root',
        cname: domain['cname'],
        ips: domain_ips,
        created_at: Time.current,
        status: 'pending_dns_setup',
        dns_records: domain_ips.any? ?
                       domain_ips.map { |ip| { type: 'A', name: '@', value: ip } } :
                       [{ type: 'CNAME', name: '@', value: domain['cname'] }]
      }

      # Create configuration for www domain
      www_dns_config = {
        hostname: www_hostname,
        type: 'www',
        cname: root_domain['cname'],
        ips: www_ips,
        created_at: Time.current,
        status: 'pending_dns_setup',
        dns_records: [{ type: 'CNAME', name: 'www', value: root_domain['cname'] }]
      }

      # Add both configurations as separate entries
      current_dns_configs[domain_hostname] = root_dns_config
      current_dns_configs[www_hostname] = www_dns_config

      # Save to user_setup
      if user.user_setup
        user.user_setup.update!(dns_configurations: current_dns_configs)
      else
        user.create_user_setup!(dns_configurations: current_dns_configs)
      end

      Rails.logger.info "DNS configurations saved for #{domain_hostname} and #{www_hostname}"

      # Create notification with DNS setup instructions
      dns_info = {
        domain_hostname: domain_hostname,
        www_hostname: www_hostname,
        domain_cname: domain['cname'],
        www_cname: root_domain['cname'],
        domain_ips: domain_ips,
        www_ips: www_ips,
        created_at: Time.current,
        status: 'pending_dns_setup'
      }
      send_dns_setup_notification(user, dns_info)

      Rails.logger.info "Website published successfully for #{website.domain_name}"

    rescue => e
      Rails.logger.error "Failed to publish website for user #{user_id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      # Re-raise the exception to let Sidekiq handle retries
      raise e
    end
  end

  private

  def resolve_dns_with_retry(hostname, max_retries = 3)
    retries = 0

    while retries < max_retries
      begin
        # Try using system dig command first
        dig_result = `dig +short #{hostname} 2>/dev/null`.strip

        if dig_result.present?
          ips = dig_result.split("\n").reject(&:blank?)
          if ips.any?
            Rails.logger.info "Resolved #{hostname} to: #{ips.join(', ')}"
            return ips
          end
        end

        # Fallback to Ruby resolver
        resolver = Resolv::DNS.new
        a_records = resolver.getaddresses(hostname)

        if a_records.any?
          ips = a_records.map(&:to_s)
          Rails.logger.info "Resolved #{hostname} to: #{ips.join(', ')}"
          return ips
        end

        Rails.logger.warn "Attempt #{retries + 1}: No IPs found for #{hostname}"
        sleep(10) if retries < max_retries - 1

      rescue => e
        Rails.logger.error "DNS resolution error on attempt #{retries + 1}: #{e.message}"
      end

      retries += 1
    end

    Rails.logger.error "Failed to resolve #{hostname} after #{max_retries} attempts"
    []
  end

  def send_dns_setup_notification(user, dns_info)
    # Send email or create notification with DNS setup instructions
    message = build_dns_setup_message(dns_info)

    # Create a notification record
    Notification.create(
      user: user,
      message: message,
      notification_type: 'dns_setup',
      read: false
    )

    Rails.logger.info "DNS setup notification created for user #{user.id}"
  end

  def build_dns_setup_message(dns_info)
    message = "Your website has been published! Please set up the following DNS records:\n\n"

    message += "For #{dns_info[:domain_hostname]}:\n"
    if dns_info[:domain_ips].any?
      dns_info[:domain_ips].each do |ip|
        message += "  Type: A, Name: @, Value: #{ip}\n"
      end
    else
      message += "  Type: CNAME, Name: @, Value: #{dns_info[:domain_cname]}\n"
    end

    message += "\nFor #{dns_info[:www_hostname]}:\n"
    message += "  Type: CNAME, Name: www, Value: #{dns_info[:www_cname]}\n"

    message += "\nDNS changes may take up to 48 hours to propagate."
    message
  end
end