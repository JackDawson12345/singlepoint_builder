class FrontendController < ApplicationController
  # Skip browser compatibility check entirely for this controller
  skip_before_action :verify_authenticity_token, if: -> { is_custom_domain? }, raise: false

  def home
    Rails.logger.info "=== FRONTEND CONTROLLER DEBUG ==="
    Rails.logger.info "Request host: #{request.host}"
    Rails.logger.info "Is main domain: #{is_main_domain?}"
    Rails.logger.info "Is custom domain: #{is_custom_domain?}"
    Rails.logger.info "Current website: #{current_website.inspect}"
    Rails.logger.info "==============================="

    # If this is a custom domain request, handle it as a public website
    if is_custom_domain? && current_website
      Rails.logger.info "Custom domain detected - serving public website content"
      serve_public_website
    else
      Rails.logger.info "Main domain detected - serving frontend home"
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

  private

  def serve_public_website
    @page_slug = params[:page_slug] || 'home'
    @page_data = find_page_data(@page_slug)

    unless @page_data
      @page_data = find_page_data('home') || find_default_page
    end

    @page_title = @page_data&.dig('title') || current_website.name
    @page_description = @page_data&.dig('description') || current_website.description

    Rails.logger.info "Serving page '#{@page_slug}' for website '#{current_website.name}' (#{current_website.domain_name})"
    Rails.logger.info "Page data found: #{@page_data.present?}"

    # For now, render a simple success message to confirm it's working
    render plain: "SUCCESS! Website: #{current_website.name} | Page: #{@page_slug} | Domain: #{current_website.domain_name}"
  end

  def find_page_data(slug)
    return nil unless current_website&.pages

    pages = current_website.pages['theme_pages'] || {}
    pages[slug] || pages[slug.to_s]
  end

  def find_default_page
    return nil unless current_website&.pages

    pages = current_website.pages['theme_pages'] || {}
    ['home', 'index', 'main'].each do |default_slug|
      page = pages[default_slug]
      return page if page
    end

    pages.values.first
  end
end