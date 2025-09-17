# app/services/login_activity_tracker.rb
class LoginActivityTracker
  def self.track(user, request)
    user_agent = UserAgent.parse(request.user_agent)

    # Get location data from ipapi.com
    location_data = get_location_data(request.remote_ip)

    login_activity = user.login_activities.create!(
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      device: detect_device(user_agent),
      browser: "#{user_agent.browser} #{user_agent.version}",
      location: location_data[:location],
      city: location_data[:city],
      country: location_data[:country],
      login_at: Time.current
    )

    # Optional: Clean up old login activities (keep last 50)
    cleanup_old_activities(user)

    login_activity
  end

  private

  def self.detect_device(user_agent)
    # Check for mobile first
    return 'Mobile' if user_agent.mobile?

    # Check for tablet by examining the user agent string
    user_agent_string = user_agent.to_s.downcase

    tablet_indicators = [
      'ipad', 'tablet', 'kindle', 'silk/', 'playbook', 'bb10',
      'rimtablet', 'android.*mobile.*safari', 'android(?!.*mobile)'
    ]

    tablet_indicators.each do |indicator|
      if user_agent_string.match(/#{indicator}/i)
        return 'Tablet'
      end
    end

    # Special case for Android tablets (Android without "Mobile" in user agent)
    if user_agent_string.include?('android') && !user_agent_string.include?('mobile')
      return 'Tablet'
    end

    # Default to desktop
    'Desktop'
  end

  def self.get_location_data(ip_address)
    return default_location_data if ip_address.blank? || local_ip?(ip_address)

    begin
      # Check cache first (ipapi.com has 1000 requests/month limit)
      cache_key = "ipapi_#{ip_address}"
      cached_result = Rails.cache.read(cache_key)

      if cached_result
        Rails.logger.info "Using cached location data for IP: #{ip_address}"
        return cached_result
      end

      # Make API call to ipapi.com
      Rails.logger.info "Fetching location data from ipapi.com for IP: #{ip_address}"
      result = Geocoder.search(ip_address).first

      if result && result.city.present?
        location_data = {
          location: format_location(result),
          city: result.city || 'Unknown',
          country: result.country || 'Unknown'
        }

        # Cache for 30 days (since IP locations don't change often)
        Rails.cache.write(cache_key, location_data, expires_in: 30.days)

        Rails.logger.info "Successfully geocoded IP #{ip_address}: #{location_data[:location]}"
        return location_data
      else
        Rails.logger.warn "No location data found for IP: #{ip_address}"
        return default_location_data
      end

    rescue Geocoder::OverQueryLimitError => e
      Rails.logger.error "ipapi.com quota exceeded: #{e.message}"
      return default_location_data
    rescue => e
      Rails.logger.error "Geocoding error for IP #{ip_address}: #{e.message}"
      return default_location_data
    end
  end

  def self.format_location(result)
    parts = []
    parts << result.city if result.city.present?
    parts << result.state if result.state.present? && result.state != result.city
    parts << result.country if result.country.present?

    parts.any? ? parts.join(', ') : 'Unknown'
  end

  def self.local_ip?(ip_address)
    return true if ip_address.blank?

    # IPv4 localhost and private ranges
    return true if ['127.0.0.1', 'localhost'].include?(ip_address)
    return true if ip_address.match(/^192\.168\./)
    return true if ip_address.match(/^10\./)
    return true if ip_address.match(/^172\.(1[6-9]|2[0-9]|3[0-1])\./)

    # IPv6 localhost and private ranges
    return true if ['::1', '0:0:0:0:0:0:0:1'].include?(ip_address)
    return true if ip_address.match(/^fe80:/i)  # Link-local
    return true if ip_address.match(/^fc00:/i)  # Unique local
    return true if ip_address.match(/^fd00:/i)  # Unique local

    false
  end

  def self.default_location_data
    {
      location: 'Local/Unknown',
      city: 'Unknown',
      country: 'Unknown'
    }
  end

  def self.cleanup_old_activities(user)
    return unless user.login_activities.count > 50

    old_activities = user.login_activities
                         .order(login_at: :desc)
                         .offset(50)

    LoginActivity.where(id: old_activities.select(:id)).delete_all
  end
end