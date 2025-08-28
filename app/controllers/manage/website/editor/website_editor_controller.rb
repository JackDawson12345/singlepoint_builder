class Manage::Website::Editor::WebsiteEditorController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manage!
  before_action :has_website
  before_action :start_editing
  layout 'editor'
  def index
    load_page_data("/")
    render :show
  end

  def show
    load_page_data(params[:page_slug])

    if @page_data.nil?
      redirect_to manage_website_website_editor_path, alert: "Page not found"
      return
    end
  end

  def sidebar_data
    title = params[:title]

    begin
      respond_to do |format|
        format.json do
          render json: {
            html: render_to_string(partial: 'editor_sidebar', locals: { title: title }),
            success: true
          }
        end
      end
    rescue => e
      Rails.logger.error "Sidebar data error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      respond_to do |format|
        format.json do
          render json: { error: e.message }, status: 500
        end
      end
    end
  end

  private

  def load_page_data(slug)
    @website = current_user.website # Adjust this to however you're finding the website
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

  def start_editing
    if current_user.user_setup.built_website == 'Not Started'
      current_user.user_setup.update(built_website: 'Started')
    end
  end
end
