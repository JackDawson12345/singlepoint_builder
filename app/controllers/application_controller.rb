class ApplicationController < ActionController::Base


  # Add multi-tenant domain detection before all actions
  before_action :find_current_website, if: -> { Rails.env.production? }
  helper_method :popular_fonts

  protected

  def after_sign_in_path_for(resource)
    if resource.role == 0
      '/admin'
    elsif resource.role == 1
      '/manage'
    else
      root_path # fallback for other roles or nil
    end
  end


  private

  # Multi-tenant domain detection
  def find_current_website
    # Extract domain from request, removing port if present
    domain = request.host.downcase.split(':').first

    # Remove www prefix for consistency
    domain_without_www = domain.sub(/^www\./, '')

    # Try to find website by domain (with or without www)
    @current_website = Website.find_by(domain_name: [domain, domain_without_www])

    # Store the detected domain type for later use
    @is_custom_domain = !is_main_domain?(domain)

    # Enhanced logging for debugging
    Rails.logger.info "=== DOMAIN DEBUG ==="
    Rails.logger.info "Raw host: #{request.host}"
    Rails.logger.info "Domain detected: #{domain}"
    Rails.logger.info "Domain without www: #{domain_without_www}"
    Rails.logger.info "Is custom domain: #{@is_custom_domain}"
    Rails.logger.info "Website found: #{@current_website.present?}"
    Rails.logger.info "Website name: #{@current_website&.name}"
    Rails.logger.info "ENV HEROKU_APP_NAME: #{ENV['HEROKU_APP_NAME']}"
    Rails.logger.info "ENV MAIN_DOMAIN: #{ENV['MAIN_DOMAIN']}"
    Rails.logger.info "=================="
  end

  def is_main_domain?(domain = nil)
    domain ||= request.host.downcase.split(':').first
    domain_without_www = domain.sub(/^www\./, '')

    main_domains = [
      'localhost',                    # Development
      '127.0.0.1',                   # Development
      ENV['MAIN_DOMAIN'],            # Production main domain from env
      "#{ENV['HEROKU_APP_NAME']}.herokuapp.com",  # Heroku app domain
      'single-point-commerce-c9fbd3b6fe59.herokuapp.com'  # Hardcoded fallback
    ].compact.map(&:downcase)

    # Remove empty strings
    main_domains = main_domains.reject(&:empty?)

    Rails.logger.info "Main domains list: #{main_domains}"
    Rails.logger.info "Checking domain: #{domain} and #{domain_without_www}"
    Rails.logger.info "Domain match result: #{main_domains.include?(domain) || main_domains.include?(domain_without_www)}"

    main_domains.include?(domain) || main_domains.include?(domain_without_www)
  end

  def current_website
    @current_website
  end

  def is_custom_domain?
    @is_custom_domain
  end

  # Handle unmatched domains
  def domain_not_found
    render file: 'public/404.html', status: :not_found, layout: false
  end

  # Make these methods available in views
  helper_method :current_website, :is_custom_domain?, :is_main_domain?

  public

  def notify_all_admins(message, notification_type = 'announcement')
    admin_users = User.where(role: 0) # or User.admin if using enum

    notification_data = admin_users.map do |user|
      {
        user_id: user.id,
        message: message,
        notification_type: notification_type,
        read: false,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Notification.insert_all(notification_data)
  end

  def component_types
    [
      'Header',
      'Footer',
      'Breadcrumbs',
      'Tabs',
      'Hero Section',
      'Content Section',
      'Card',
      'Article/Blog Post',
      'Image Gallery',
      'Carousel/Slider',
      'Accordion',
      'Search Bar',
      'Progress Bar',
      'Rating/Stars',
      'Comments Section',
      'Social Share Buttons',
      'Testimonial',
      'Banner',
      'Call-to-Action',
      'Products',
      'Services',
      'Blogs',
      'Service Inner',
      'Blog Inner',
      'Product Inner',
      'Login Section',
      'Sign Up Section'
    ]
  end

  def popular_fonts
    [
      "Roboto",
      "Open Sans",
      "Lato",
      "Montserrat",
      "Oswald",
      "Source Sans 3",
      "Slabo",
      "Raleway",
      "PT Sans",
      "Merriweather",
      "Noto Sans",
      "Nunito Sans",
      "Poppins",
      "Roboto Condensed",
      "Playfair Display",
      "Ubuntu",
      "Lora",
      "Dosis",
      "Droid Sans",
      "Quicksand",
      "Rubik",
      "PT Serif",
      "Zilla Slab",
      "Bitter",
      "Libre Baskerville",
      "Arvo",
      "Inter",
      "Rubik",
      "Work Sans"
    ]
  end
end