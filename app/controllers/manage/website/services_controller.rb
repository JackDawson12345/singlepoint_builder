# app/controllers/manage/website/services_controller.rb
class Manage::Website::ServicesController < Manage::BaseController
  before_action :set_website
  before_action :set_service, only: [:show, :edit, :update, :destroy]
  before_action :set_service_index, only: [:edit, :update, :destroy]

  def index
    @services = @website.services || []
  end

  def show
    @service_page = current_user.website.pages["theme_pages"]["services"]
  end

  def new
    @service = {
      "id" => SecureRandom.uuid,
      "name" => "",
      "slug" => "",
      "content" => "",
      "excerpt" => "",
      "featured_image" => "",
      "categories" => [],
      "parent_page" => nil
    }
  end

  def create
    @service = service_params.to_h
    @service["id"] = SecureRandom.uuid

    # Handle file upload for featured_image
    if params[:service][:featured_image].present?
      uploaded_file = params[:service][:featured_image]
      blob = ActiveStorage::Blob.create_and_upload!(
        io: uploaded_file.open,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type
      )
      @service["featured_image"] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end

    # Handle parent page - save full page information
    if @service["parent_page"].present?
      page_data = @website.pages["theme_pages"].find { |name, page| page["slug"] == @service["parent_page"] }
      if page_data
        page_name, page_info = page_data
        @service["parent_page"] = {
          "name" => page_name,
          "slug" => page_info["slug"],
          "theme_page_id" => page_info["theme_page_id"]
        }
      end
    else
      @service["parent_page"] = nil
    end

    # Handle categories - convert comma-separated string to array
    if @service["categories"].present?
      @service["categories"] = @service["categories"].split(',').map(&:strip).reject(&:blank?)
    end

    # Generate slug from name if not provided
    @service["slug"] = @service["name"].parameterize if @service["slug"].blank?

    services = @website.services || []
    services << @service

    service_page = current_user.website.pages["theme_pages"]["services"]

    if service_page.present?
      # Calculate the next position
      next_position = if service_page['inner_pages'].empty?
                        1
                      else
                        service_page['inner_pages'].values.map { |page| page['position'].to_i }.max + 1
                      end

      service_page['inner_pages'][@service['name']] = {
        "theme_page_id" => @service['id'],
        "components" => service_page['inner_pages_components'],
        "slug" => @service['slug'],
        "position" => next_position.to_s,
        "seo" => {"focus_keyword" => '',
                  "title_tag" => '',
                  "meta_description" => ''}
      }
    else

    end

    if @website.update(services: services)
      redirect_to manage_website_service_path(@service["id"]), notice: 'Service was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    # Handle file upload for featured_image
    if params[:service][:featured_image].present?
      uploaded_file = params[:service][:featured_image]
      blob = ActiveStorage::Blob.create_and_upload!(
        io: uploaded_file.open,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type
      )
      service_params_hash = service_params.to_h
      service_params_hash["featured_image"] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    else
      service_params_hash = service_params.to_h
      service_params_hash["featured_image"] = @service["featured_image"] # Keep existing image
    end

    # Handle parent page - save full page information
    if service_params_hash["parent_page"].present?
      page_data = @website.pages["theme_pages"].find { |name, page| page["slug"] == service_params_hash["parent_page"] }
      if page_data
        page_name, page_info = page_data
        service_params_hash["parent_page"] = {
          "name" => page_name,
          "slug" => page_info["slug"],
          "theme_page_id" => page_info["theme_page_id"]
        }
      end
    else
      service_params_hash["parent_page"] = nil
    end

    # Handle categories - convert comma-separated string to array
    if service_params_hash["categories"].present?
      service_params_hash["categories"] = service_params_hash["categories"].split(',').map(&:strip).reject(&:blank?)
    end

    # Generate slug from name if not provided
    service_params_hash["slug"] = service_params_hash["name"].parameterize if service_params_hash["slug"].blank?

    services = @website.services
    services[@service_index] = service_params_hash.merge("id" => @service["id"])

    if @website.update(services: services)
      redirect_to manage_website_service_path(@service["id"]), notice: 'Service was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    services = @website.services
    services.delete_at(@service_index)

    if @website.update(services: services)
      redirect_to manage_website_services_path, notice: 'Service was successfully deleted.'
    else
      redirect_to manage_website_services_path, alert: 'Failed to delete service.'
    end
  end

  def categories
    # Initialize categories structure if it doesn't exist
    categories = @website.categories || {}
    categories["blogs"] ||= {}
    categories["services"] ||= {}
    categories["products"] ||= {}

    @service_categories = categories["services"]

    # Create a new category object for the form
    @new_category = {
      "id" => SecureRandom.uuid,
      "name" => "",
      "slug" => "",
      "parent_category" => "",
      "description" => "",
      "image" => "",
      "seo" => {"focus_keyword" => '',
                "title_tag" => '',
                "meta_description" => ''}
    }
  end

  def create_category
    @category = category_params.to_h
    @category["id"] = SecureRandom.uuid
    @category['seo'] = {"focus_keyword" => '',
                        "title_tag" => '',
                        "meta_description" => ''}

    # Handle file upload for category image
    if params[:category][:image].present?
      uploaded_file = params[:category][:image]
      blob = ActiveStorage::Blob.create_and_upload!(
        io: uploaded_file.open,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type
      )
      @category["image"] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end

    # Generate slug from name if not provided
    @category["slug"] = @category["name"].parameterize if @category["slug"].blank?

    # Get existing categories or initialize
    categories = @website.categories || {}
    categories["blogs"] ||= {}
    categories["services"] ||= {}
    categories["products"] ||= {}

    # Add new category to blogs categories
    categories["services"][@category["id"]] = @category

    if @website.update(categories: categories)
      redirect_to categories_manage_website_services_path, notice: 'Blog category was successfully created.'
    else
      @blog_categories = categories["services"]
      @new_category = @category
      render :categories
    end
  end

  private

  def set_website
    @website = current_user.website
  end

  def set_service
    services = @website.services || []
    @service = services.find { |s| s["id"] == params[:id] }
    redirect_to manage_website_services_path, alert: 'Service not found.' unless @service
  end

  def set_service_index
    services = @website.services || []
    @service_index = services.find_index { |s| s["id"] == params[:id] }
  end

  def service_params
    params.require(:service).permit(:name, :slug, :content, :excerpt, :categories, :parent_page)
  end
  def category_params
    params.require(:category).permit(:name, :slug, :parent_category, :description, :image)
  end
end