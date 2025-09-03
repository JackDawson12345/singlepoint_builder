# app/controllers/public_websites_controller.rb
class PublicWebsitesController < ApplicationController
  # Skip any authentication since these are public websites
  skip_before_action :verify_authenticity_token, only: [:show]

  # Use the public website layout
  layout 'public_website'

  def show
    # Enhanced logging for debugging
    Rails.logger.info "=== PUBLIC WEBSITES CONTROLLER DEBUG ==="
    Rails.logger.info "Request host: #{request.host}"
    Rails.logger.info "Is main domain: #{is_main_domain?}"
    Rails.logger.info "Is custom domain: #{is_custom_domain?}"
    Rails.logger.info "Current website: #{current_website.inspect}"
    Rails.logger.info "======================================="

    # Handle main domain vs custom domain logic
    if is_main_domain?
      # Redirect to manage interface for main domain
      Rails.logger.info "Redirecting to manage interface (main domain detected)"
      redirect_to '/manage/setup' and return
    end

    # If no website found for this domain, show 404
    unless current_website
      Rails.logger.info "No website found for domain, showing 404"
      render file: 'public/404.html', status: :not_found, layout: false
      return
    end

    # Get the page slug from params or default to 'home'
    @page_slug = params[:page_slug] || 'home'

    # Find the page data
    @page_data = find_page_data(@page_slug)

    # If page not found, try to find a default page
    unless @page_data
      @page_data = find_page_data('home') || find_default_page
    end

    # Set page title and meta data for the layout
    @page_title = @page_data&.dig('title') || current_website.name
    @page_description = @page_data&.dig('description') || current_website.description

    # Log for debugging
    Rails.logger.info "Serving page '#{@page_slug}' for website '#{current_website.name}' (#{current_website.domain_name})"
    Rails.logger.info "Page data found: #{@page_data.present?}"
    Rails.logger.info "Page data: #{@page_data.inspect}" if @page_data

    # Rails will automatically render app/views/public_websites/show.html.erb
    # with the public_website layout
  end

  # Handle all other routes that don't match specific pages
  def catch_all
    # Redirect to the custom domain root
    redirect_to custom_domain_root_path
  end

  private

  def find_page_data(slug)
    return nil unless current_website&.pages

    # Based on your existing page structure from the setup controller
    pages = current_website.pages['theme_pages'] || {}

    Rails.logger.info "Available pages: #{pages.keys.inspect}"

    # Try to find the exact page
    page = pages[slug] || pages[slug.to_s]

    # If not found, try common variations
    unless page
      # Try with underscores instead of hyphens
      alt_slug = slug.tr('-', '_')
      page = pages[alt_slug]
      Rails.logger.info "Tried alternative slug '#{alt_slug}': #{page.present?}" if alt_slug != slug
    end

    # If still not found, try case-insensitive search
    unless page
      pages.each do |key, value|
        if key.to_s.downcase == slug.downcase
          page = value
          Rails.logger.info "Found case-insensitive match for '#{slug}' with key '#{key}'"
          break
        end
      end
    end

    Rails.logger.info "Final page result for '#{slug}': #{page.present? ? 'found' : 'not found'}"
    page
  end

  def find_default_page
    return nil unless current_website&.pages

    pages = current_website.pages['theme_pages'] || {}

    # Try common home page names
    ['home', 'index', 'main', 'landing'].each do |default_slug|
      page = pages[default_slug] || pages[default_slug.to_s]
      if page
        Rails.logger.info "Using default page: #{default_slug}"
        return page
      end
    end

    # Return the first page if no home page found
    first_page = pages.values.first
    Rails.logger.info "Using first available page as default: #{first_page.present? ? 'found' : 'none available'}"
    first_page
  end
end