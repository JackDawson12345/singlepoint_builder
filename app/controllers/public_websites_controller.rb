# app/controllers/public_websites_controller.rb
class PublicWebsitesController < ApplicationController
  # Skip CSRF for public websites (if needed)
  # Note: Only add this if you have authentication/CSRF protection elsewhere
  # skip_before_action :verify_authenticity_token, only: [:show]

  def show
    # If no website found for this domain, show 404
    unless current_website
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

    # Set page title and meta
    @page_title = @page_data&.dig('title') || current_website.name
    @page_description = @page_data&.dig('description') || current_website.description

    # Log for debugging
    Rails.logger.info "Serving page '#{@page_slug}' for website '#{current_website.name}' (#{current_website.domain_name})"

    render 'public_websites/show', layout: 'public_website'
  end

  # Handle all other routes that don't match specific pages
  def catch_all
    # Redirect to home page
    redirect_to root_path
  end

  private

  def find_page_data(slug)
    return nil unless current_website&.pages

    # Based on your existing page structure from the setup controller
    pages = current_website.pages['theme_pages'] || {}

    # Try to find the exact page
    page = pages[slug] || pages[slug.to_s]

    # If not found, try common variations
    unless page
      # Try with underscores instead of hyphens
      alt_slug = slug.tr('-', '_')
      page = pages[alt_slug]
    end

    page
  end

  def find_default_page
    return nil unless current_website&.pages

    pages = current_website.pages['theme_pages'] || {}

    # Try common home page names
    ['home', 'index', 'main'].each do |default_slug|
      page = pages[default_slug]
      return page if page
    end

    # Return the first page if no home page found
    pages.values.first
  end
end