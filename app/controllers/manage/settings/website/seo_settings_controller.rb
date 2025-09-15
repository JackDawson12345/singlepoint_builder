class Manage::Settings::Website::SeoSettingsController < Manage::BaseController
  # In your settings controller (e.g., app/controllers/manage/settings_controller.rb)

  def update_seo_field
    begin
      page_name = params[:page_name]
      field = params[:field]
      value = params[:value]
      page_type = params[:page_type] || 'main'
      outer_page_name = params[:outer_page_name]
      category_id = params[:category_id]

      # Validate the field name for security
      allowed_fields = %w[focus_keyword title_tag meta_description]
      unless allowed_fields.include?(field)
        render json: { success: false, message: 'Invalid field' }, status: :bad_request
        return
      end

      # Validate page type
      unless %w[main service blog_category service_category].include?(page_type)
        render json: { success: false, message: 'Invalid page type' }, status: :bad_request
        return
      end

      # Access the website
      website = current_user.website
      success = false

      if page_type == 'main'
        # Handle main pages (theme_pages)
        pages_data = website.pages.deep_dup

        if pages_data["theme_pages"] &&
           pages_data["theme_pages"][page_name] &&
           pages_data["theme_pages"][page_name]["seo"]

          pages_data["theme_pages"][page_name]["seo"][field] = value
          website.update!(pages: pages_data)
          success = true
        end

      elsif page_type == 'service'
        # Handle service pages (inner_pages)
        if outer_page_name.blank?
          render json: { success: false, message: 'Outer page name required for service pages' }, status: :bad_request
          return
        end

        pages_data = website.pages.deep_dup

        if pages_data["theme_pages"] &&
           pages_data["theme_pages"][outer_page_name] &&
           pages_data["theme_pages"][outer_page_name]["inner_pages"] &&
           pages_data["theme_pages"][outer_page_name]["inner_pages"][page_name] &&
           pages_data["theme_pages"][outer_page_name]["inner_pages"][page_name]["seo"]

          pages_data["theme_pages"][outer_page_name]["inner_pages"][page_name]["seo"][field] = value
          website.update!(pages: pages_data)
          success = true
        end

      elsif page_type == 'blog_category'
        # Handle blog categories
        if category_id.blank?
          render json: { success: false, message: 'Category ID required for blog categories' }, status: :bad_request
          return
        end

        categories_data = website.categories.deep_dup

        if categories_data["blogs"] &&
           categories_data["blogs"][category_id] &&
           categories_data["blogs"][category_id]["seo"]

          categories_data["blogs"][category_id]["seo"][field] = value
          website.update!(categories: categories_data)
          success = true
        end

      elsif page_type == 'service_category'
        # Handle service categories
        if category_id.blank?
          render json: { success: false, message: 'Category ID required for service categories' }, status: :bad_request
          return
        end

        categories_data = website.categories.deep_dup

        if categories_data["services"] &&
           categories_data["services"][category_id] &&
           categories_data["services"][category_id]["seo"]

          categories_data["services"][category_id]["seo"][field] = value
          website.update!(categories: categories_data)
          success = true
        end
      end

      if success
        render json: {
          success: true,
          message: 'Field updated successfully',
          page_name: page_name,
          field: field,
          value: value,
          page_type: page_type,
          outer_page_name: outer_page_name,
          category_id: category_id
        }
      else
        render json: { success: false, message: 'Page/Category not found' }, status: :not_found
      end

    rescue => e
      Rails.logger.error "Error updating SEO field: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { success: false, message: 'An error occurred while updating the field' }, status: :internal_server_error
    end
  end

  # For your controller actions that render the views:
  def main_page_settings
    @pages = current_user.website.pages["theme_pages"] || {}
  end

  def services_settings
    # Get all service pages from the services main page
    services_main_page = current_user.website.pages["theme_pages"]["services"]
    @service_pages = services_main_page&.dig("inner_pages") || {}
  end

  def service_categories_settings
    @service_categories = current_user.website.categories['services'] || {}
  end

  def blog_categories_settings
    @blog_categories = current_user.website.categories['blogs'] || {}
  end

  def blog_posts_settings
    @blog_pages = current_user.website.pages["theme_pages"]["news"]['inner_pages'] || {}
  end

  def products_settings
    @shop_pages = current_user.website.pages["theme_pages"]["shop"]['inner_pages'] || {}
  end

  # Helper method that you're already using in your view
  def find_outer_page_data(service_page, all_pages)
    theme_pages = all_pages["theme_pages"] || {}

    theme_pages.each do |main_page_name, main_page_data|
      if main_page_data["inner_pages"].present?
        main_page_data["inner_pages"].each do |service_name, service_data|
          if service_data["theme_page_id"] == service_page["theme_page_id"]
            return [main_page_name, main_page_data]
          end
        end
      end
    end

    [nil, nil]
  end
end
