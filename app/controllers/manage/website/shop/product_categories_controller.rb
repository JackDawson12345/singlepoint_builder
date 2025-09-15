class Manage::Website::Shop::ProductCategoriesController < Manage::BaseController
  before_action :set_website

  def index
    # Initialize categories structure if it doesn't exist
    categories = @website.categories || {}
    categories["blogs"] ||= {}
    categories["services"] ||= {}
    categories["products"] ||= {}

    @product_categories = categories["products"]

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

    # Add new category to products categories
    categories["products"][@category["id"]] = @category

    if @website.update(categories: categories)
      redirect_to manage_website_shop_categories_path, notice: 'Product category was successfully created.'
    else
      @product_categories = categories["products"]
      @new_category = @category
      render :categories
    end
  end

  private

  def set_website
    @website = current_user.website
  end

  def category_params
    params.require(:category).permit(:name, :slug, :parent_category, :description, :image)
  end
end
