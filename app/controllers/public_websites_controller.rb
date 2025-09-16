# app/controllers/public_websites_controller.rb
class PublicWebsitesController < ApplicationController
  # Skip any authentication since these are public websites
  skip_before_action :verify_authenticity_token, only: [:show]

  # Use the public website layout
  layout 'public_website'

  def show
    if request.path.start_with?('/admin', '/manage', '/up', '/users/sign_in', '/users/sign_out')
      raise ActionController::RoutingError, 'Not Found'
    end

    # Handle main domain vs custom domain logic
    if is_main_domain?
      # If accessing root path and no specific page requested, show frontend
      if request.path == '/' && params[:page_slug].blank?
        Rails.logger.info "Serving frontend home page for main domain"
        render template: 'frontend/home', layout: 'frontend'
        return
      else
        # For any other paths on main domain, redirect to manage
        Rails.logger.info "Redirecting to manage interface (main domain detected)"
        redirect_to '/manage/setup' and return
      end
    end

    # If no website found for this domain, show 404
    unless current_website
      Rails.logger.info "No website found for domain, showing 404"
      render file: 'public/404.html', status: :not_found, layout: false
      return
    end

    # Check if this is an inner page request
    if params[:inner_page_slug]
      load_inner_page_data(params[:page_slug], params[:inner_page_slug])
    else
      # Get the page slug from params or default to 'home'
      @page_slug = params[:page_slug] || 'home'
      load_page_data(@page_slug)
    end

    # If page not found, try to find a default page
    unless @page_data
      @page_data = find_page_data('home') || find_default_page
    end

    # Set page title and meta data for the layout
    @page_title = @page_data&.dig('title') || current_website.name
    @page_description = @page_data&.dig('description') || current_website.description

    # Log for debugging
    page_info = params[:inner_page_slug] ? "#{@page_slug}/#{params[:inner_page_slug]}" : @page_slug
    Rails.logger.info "Serving page '#{page_info}' for website '#{current_website.name}' (#{current_website.domain_name})"
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

  def load_page_data(slug)
    @website = current_website
    @page_slug = slug

    pages = @website.pages["theme_pages"]
    @page_data = pages.find do |key, page|
      page_slug = page["slug"]
      if slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == slug || page_slug == "/#{slug}"
      end
    end&.last
  end

  def load_inner_page_data(slug, inner_slug)
    @website = current_website
    @page_slug = slug
    @inner_page_slug = inner_slug

    pages = @website.pages["theme_pages"]
    @all_page_data = pages.find do |key, page|
      page_slug = page["slug"]
      if slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == slug || page_slug == "/#{slug}"
      end
    end&.last

    return unless @all_page_data&.dig('inner_pages')

    # Capture both the key (page name) and the data
    @page_name, @page_data = @all_page_data['inner_pages'].find do |key, page|
      page_slug = page["slug"]
      if inner_slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == inner_slug || page_slug == "/#{inner_slug}"
      end
    end
  end

  def find_page_data(slug)
    return nil unless current_website&.pages

    @website = current_website
    @page_slug = slug

    pages = @website.pages["theme_pages"]
    @page_data = pages.find do |key, page|
      page_slug = page["slug"]
      if slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == slug || page_slug == "/#{slug}"
      end
    end&.last
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