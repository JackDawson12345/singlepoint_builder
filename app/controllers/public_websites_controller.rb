# app/controllers/public_websites_controller.rb
class PublicWebsitesController < ApplicationController
  skip_before_action :authenticate_user!  # If using Devise

  def show
    return redirect_to_main_site unless current_website

    @page_slug = params[:page_slug] || 'home'
    @page_data = find_page_data(@page_slug)

    render 'public_websites/show', layout: 'public_website'
  end

  private

  def find_page_data(slug)
    return nil unless current_website&.pages

    # Based on your existing page structure
    pages = current_website.pages['theme_pages'] || {}
    pages[slug] || pages['home'] || pages.values.first
  end

  def redirect_to_main_site
    redirect_to "https://your-main-app.herokuapp.com"
  end
end