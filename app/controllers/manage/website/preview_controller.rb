class Manage::Website::PreviewController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manage!
  before_action :has_website
  layout 'preview'
  def index
    load_page_data("/")
    render :show
  end

  def inner_page
    load_inner_page_data(params[:page_slug], params[:inner_page_slug])
    render :show
  end

  def show
    load_page_data(params[:page_slug])

    if @page_data.nil?
      redirect_to manage_website_website_editor_path, alert: "Page not found"
      return
    end
  end

  private

  def load_page_data(slug)
    @website = current_user.website
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
    @website = current_user.website
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

  def ensure_manage!
    if current_user.role == 1

    elsif current_user.role == 0
      redirect_to admin_dashboard_path, alert: 'Access denied. Manage privileges required.'
    else
      redirect_to root_path, alert: 'Access denied. Manage privileges required.'
    end
  end

  def has_website
    unless current_user.website
      redirect_to manage_setup_path, alert: 'Please Set Up Your Website.'
    end
  end
end
