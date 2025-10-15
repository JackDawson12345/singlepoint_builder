class FrontendController < ApplicationController
  # Skip browser compatibility check entirely for this controller
  skip_before_action :verify_authenticity_token, if: -> { is_custom_domain? }, raise: false
  layout 'frontend'


  def home
    # If this is a custom domain request, handle it as a public website
    if is_custom_domain? && current_website
      serve_public_website
    else
      # Your existing frontend home logic - render the normal frontend view
      # Add any existing logic you had in the home method here
    end
  end

  def about
    # Your existing about method
  end

  def themes
    # Your existing themes method
  end

  def contact
    # Your existing contact method
  end

  def help

  end

  def help_article
    @article = HelpArticle.find(params[:id])
  end

  # Handle page slug routes for www. domains
  def page_slug
    if is_custom_domain? && current_website
      serve_public_website
    else
      # Redirect to home or handle as needed for non-custom domains
      redirect_to root_path
    end
  end

  private

  def serve_public_website
    # Check if this is an inner page request
    if params[:inner_page_slug]
      load_inner_page_data(params[:page_slug], params[:inner_page_slug])
    else
      @page_slug = params[:page_slug] || 'home'
      load_page_data(@page_slug)
    end

    unless @page_data
      @page_data = find_page_data('home') || find_default_page
    end

    # If page still not found, render 404
    unless @page_data
      render file: 'public/404.html', status: :not_found, layout: false
      return
    end

    @page_title = @page_data&.dig('title') || current_website.name
    @page_description = @page_data&.dig('description') || current_website.description

    page_info = params[:inner_page_slug] ? "#{@page_slug}/#{params[:inner_page_slug]}" : (@page_slug || 'home')
    Rails.logger.info "Serving page '#{page_info}' for website '#{current_website.name}' (#{current_website.domain_name})"
    Rails.logger.info "Page data found: #{@page_data.present?}"
    Rails.logger.info "Page data: #{@page_data.inspect}" if @page_data

    # Render the same view as PublicWebsitesController with the public_website layout
    render 'public_websites/show', layout: 'public_website'
  end

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