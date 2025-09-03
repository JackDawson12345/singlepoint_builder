class Manage::Website::BlogsController < Manage::BaseController
  before_action :set_website
  before_action :set_blog, only: [:show, :edit, :update, :destroy]
  before_action :set_blog_index, only: [:edit, :update, :destroy]

  def index
    @blogs = @website.blogs || []
  end

  def show
  end

  def new
    @blog = {
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
    @blog = blog_params.to_h
    @blog["id"] = SecureRandom.uuid

    # Handle file upload for featured_image
    if params[:blog][:featured_image].present?
      uploaded_file = params[:blog][:featured_image]
      blob = ActiveStorage::Blob.create_and_upload!(
        io: uploaded_file.open,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type
      )
      @blog["featured_image"] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    end

    # Handle parent page - save full page information
    if @blog["parent_page"].present?
      page_data = @website.pages["theme_pages"].find { |name, page| page["slug"] == @blog["parent_page"] }
      if page_data
        page_name, page_info = page_data
        @blog["parent_page"] = {
          "name" => page_name,
          "slug" => page_info["slug"],
          "theme_page_id" => page_info["theme_page_id"]
        }
      end
    else
      @blog["parent_page"] = nil
    end

    # Handle categories - convert comma-separated string to array
    if @blog["categories"].present?
      @blog["categories"] = @blog["categories"].split(',').map(&:strip).reject(&:blank?)
    end

    # Generate slug from name if not provided
    @blog["slug"] = @blog["name"].parameterize if @blog["slug"].blank?

    blogs = @website.blogs || []
    blogs << @blog

    if @website.update(blogs: blogs)
      redirect_to manage_website_blog_path(@blog["id"]), notice: 'Blog was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    # Handle file upload for featured_image
    if params[:blog][:featured_image].present?
      uploaded_file = params[:blog][:featured_image]
      blob = ActiveStorage::Blob.create_and_upload!(
        io: uploaded_file.open,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type
      )
      blog_params_hash = blog_params.to_h
      blog_params_hash["featured_image"] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
    else
      blog_params_hash = blog_params.to_h
      blog_params_hash["featured_image"] = @blog["featured_image"] # Keep existing image
    end

    # Handle parent page - save full page information
    if blog_params_hash["parent_page"].present?
      page_data = @website.pages["theme_pages"].find { |name, page| page["slug"] == blog_params_hash["parent_page"] }
      if page_data
        page_name, page_info = page_data
        blog_params_hash["parent_page"] = {
          "name" => page_name,
          "slug" => page_info["slug"],
          "theme_page_id" => page_info["theme_page_id"]
        }
      end
    else
      blog_params_hash["parent_page"] = nil
    end

    # Handle categories - convert comma-separated string to array
    if blog_params_hash["categories"].present?
      blog_params_hash["categories"] = blog_params_hash["categories"].split(',').map(&:strip).reject(&:blank?)
    end

    # Generate slug from name if not provided
    blog_params_hash["slug"] = blog_params_hash["name"].parameterize if blog_params_hash["slug"].blank?

    blogs = @website.blogs
    blogs[@blog_index] = blog_params_hash.merge("id" => @blog["id"])

    if @website.update(blogs: blogs)
      redirect_to manage_website_blog_path(@blog["id"]), notice: 'Blog was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    blogs = @website.blogs
    blogs.delete_at(@blog_index)

    if @website.update(blogs: blogs)
      redirect_to manage_website_blogs_path, notice: 'Blog was successfully deleted.'
    else
      redirect_to manage_website_blogs_path, alert: 'Failed to delete blog.'
    end
  end

  private

  def set_website
    @website = current_user.website
  end

  def set_blog
    blogs = @website.blogs || []
    @blog = blogs.find { |s| s["id"] == params[:id] }
    redirect_to manage_website_blogs_path, alert: 'Blog not found.' unless @blog
  end

  def set_blog_index
    blogs = @website.blogs || []
    @blog_index = blogs.find_index { |s| s["id"] == params[:id] }
  end

  def blog_params
    params.require(:blog).permit(:name, :slug, :content, :excerpt, :categories, :parent_page)
  end
end
