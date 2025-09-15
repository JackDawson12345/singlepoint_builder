class Manage::Website::Shop::ProductsController < Manage::BaseController
  before_action :find_product, only: [:edit, :update, :destroy, :remove_image]
  before_action :load_product_images, only: [:edit, :update]

  def new
    @product = nil
    @product_images = []
  end

  def create
    current_products = current_user.website&.products || []
    product_id = SecureRandom.uuid

    # Store product_id for variant image processing
    @product_id = product_id

    image_urls = handle_image_uploads_and_get_urls(product_id)

    url_slug = product_params[:seo_url].present? ? product_params[:seo_url].gsub(' ', '-') : product_params[:name].parameterize

    # Parse categories from comma-separated string
    categories = parse_categories_from_string(product_params[:categories])

    new_product = {
      'id' => product_id,
      'data' => {
        'name' => product_params[:name],
        'description' => product_params[:description],
        'categories' => categories # This will be an array of category IDs
      },
      'images' => image_urls,
      'price' => {
        'price' => product_params[:price].to_f,
        'sale_price' => product_params[:sale_price].to_f,
        'cost_per_item' => product_params[:cost_per_item].to_f
      },
      'inventory' => {
        'track_quantity' => product_params[:track_quantity] == '1',
        'quantity' => product_params[:quantity].to_i,
        'sell_out_of_stock' => product_params[:sell_out_of_stock] == '1',
        'has_sku_or_barcode' => product_params[:has_sku_or_barcode] == '1',
        'sku' => product_params[:sku] || '',
        'barcode' => product_params[:barcode] || ''
      },
      'shipping' => {
        'physical_product' => product_params[:physical_product] == '1',
        'weight' => product_params[:weight] || '',
        'sizes' => {
          'width' => product_params[:width] || '',
          'height' => product_params[:height] || '',
          'depth' => product_params[:depth] || ''
        }
      },
      'variants' => parse_variants_data(product_params[:variants]),
      'organization' => {
        'product_type' => product_params[:product_type] || '',
        'vendor' => product_params[:vendor] || '',
        'tags' => parse_tags(product_params[:tags])
      },
      'seo' => {
        'focus_keyword' => '',
        'title_tag' => product_params[:seo_title] || '',
        'meta_description' => product_params[:seo_description] || '',
        'url_handle' => url_slug || ''
      },
      'status' => product_params[:status] || 'active',
      'created_at' => Time.current.iso8601
    }

    current_products << new_product

    if current_user.website
      current_user.website.update(products: current_products)
    end

    # ... rest of your existing code for creating product page ...

    redirect_to manage_website_shop_products_path, notice: 'Product was successfully created!'
  end

  def edit
    # @product and @product_images are set by before_action
  end

  def update
    current_products = current_user.website.products || []
    product_index = current_products.find_index { |p| p['id'] == params[:id] }

    if product_index
      # Handle new image uploads and get existing images
      existing_images = current_products[product_index]['images'] || []
      new_image_urls = handle_image_uploads_and_get_urls(params[:id])
      all_images = existing_images + new_image_urls

      # Parse categories from comma-separated string
      categories = parse_categories_from_string(product_params[:categories])

      current_products[product_index].merge!({
                                               'data' => {
                                                 'name' => product_params[:name],
                                                 'description' => product_params[:description],
                                                 'categories' => categories # This will be an array of category IDs
                                               },
                                               'images' => all_images,
                                               'price' => {
                                                 'price' => product_params[:price].to_f,
                                                 'sale_price' => product_params[:sale_price].to_f,
                                                 'cost_per_item' => product_params[:cost_per_item].to_f
                                               },
                                               'inventory' => {
                                                 'track_quantity' => product_params[:track_quantity] == '1',
                                                 'quantity' => product_params[:quantity].to_i,
                                                 'sell_out_of_stock' => product_params[:sell_out_of_stock] == '1',
                                                 'has_sku_or_barcode' => product_params[:has_sku_or_barcode] == '1',
                                                 'sku' => product_params[:sku] || '',
                                                 'barcode' => product_params[:barcode] || ''
                                               },
                                               'shipping' => {
                                                 'physical_product' => product_params[:physical_product] == '1',
                                                 'weight' => product_params[:weight] || '',
                                                 'sizes' => {
                                                   'width' => product_params[:width] || '',
                                                   'height' => product_params[:height] || '',
                                                   'depth' => product_params[:depth] || ''
                                                 }
                                               },
                                               'variants' => parse_variants_data(product_params[:variants]),
                                               'organization' => {
                                                 'product_type' => product_params[:product_type] || '',
                                                 'vendor' => product_params[:vendor] || '',
                                                 'tags' => parse_tags(product_params[:tags])
                                               },
                                               'seo' => {
                                                 'title' => product_params[:seo_title] || '',
                                                 'description' => product_params[:seo_description] || '',
                                                 'url_handle' => product_params[:seo_url] || ''
                                               },
                                               'status' => product_params[:status] || 'active',
                                               'updated_at' => Time.current.iso8601
                                             })

      current_user.website.update(products: current_products)
      redirect_to manage_website_shop_products_path, notice: 'Product was successfully updated!'
    else
      redirect_to manage_website_shop_products_path, alert: 'Product not found!'
    end
  end

  def destroy
    current_products = current_user.website.products || []

    # Find the product and remove its images from Active Storage
    product_to_delete = current_products.find { |p| p['id'] == params[:id] }
    if product_to_delete && product_to_delete['images']
      remove_product_images_from_storage(product_to_delete['images'])
    end

    # Remove the product from the array
    current_products.reject! { |p| p['id'] == params[:id] }

    current_user.website.update(products: current_products)
    redirect_to manage_website_shop_products_path, notice: 'Product was successfully deleted!'
  end

  def remove_image
    current_products = current_user.website.products || []
    product_index = current_products.find_index { |p| p['id'] == params[:id] }

    if product_index
      images = current_products[product_index]['images'] || []
      image_to_remove = images[params[:image_index].to_i]

      # Remove from Active Storage
      remove_single_image_from_storage(image_to_remove)

      # Remove from JSON array
      images.delete_at(params[:image_index].to_i)
      current_products[product_index]['images'] = images

      current_user.website.update(products: current_products)
      flash[:notice] = 'Image removed successfully!'
    end

    redirect_to edit_manage_website_shop_product_path(params[:id])
  end

  def index
    @products = current_user.website&.products || []
  end

  def upload
    ensure_user_has_website
  end

  def import_csv
    ensure_user_has_website

    if params[:csv_file].present?
      csv_file = params[:csv_file]

      # Validate file type
      unless csv_file.content_type == 'text/csv' || csv_file.original_filename.ends_with?('.csv')
        redirect_to manage_website_shop_products_upload_csv_path,
                    alert: 'Please upload a valid CSV file.'
        return
      end

      begin
        imported_count = 0
        errors = []
        image_errors = []

        # Get existing products or initialize empty array
        current_products = current_user.website.products || []

        CSV.foreach(csv_file.path, headers: true, header_converters: :symbol) do |row|
          begin
            # Build the product data structure (this now handles images)
            product_data = build_product_data(row)

            # Add to the products array
            current_products << product_data
            imported_count += 1

          rescue => e
            errors << {
              row_number: $.,
              name: row[:name],
              errors: [e.message]
            }
          end
        end

        # Update the website with the new products
        if current_user.website.update(products: current_products)
          message_parts = ["Successfully imported #{imported_count} products!"]

          if errors.any?
            message_parts[0] = "Imported #{imported_count} products with #{errors.count} errors."
            flash[:errors] = errors
          end

          flash[:notice] = message_parts.join(' ')
        else
          flash[:alert] = "Failed to save products: #{current_user.website.errors.full_messages.join(', ')}"
        end

        redirect_to manage_website_shop_products_path

      rescue CSV::MalformedCSVError => e
        redirect_to manage_website_shop_products_upload_csv_path,
                    alert: "Invalid CSV file format: #{e.message}"
      rescue => e
        Rails.logger.error "CSV Import Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_to manage_website_shop_products_upload_csv_path,
                    alert: "An error occurred while processing the file: #{e.message}"
      end
    else
      redirect_to manage_website_shop_products_upload_csv_path,
                  alert: 'Please select a file to upload.'
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name, :description, :categories, :price, :sale_price, :cost_per_item,
      :track_quantity, :quantity, :sell_out_of_stock, :has_sku_or_barcode, :sku, :barcode,
      :physical_product, :weight, :width, :height, :depth, :status,
      :seo_title, :seo_description, :seo_url,
      :product_type, :vendor, :tags,
      images: [],
      variants: {
        options: {},
        combinations: [],
        prices: [],
        quantities: [],
        skus: [],
        images: []
      }
    )
  end

  def parse_categories_from_string(categories_string)
    return [] if categories_string.blank?

    # Split by comma and clean up each category ID
    categories_string.split(',').map(&:strip).reject(&:blank?)
  end

  def parse_variants_data(variants_params)
    # Debug logging to understand the structure
    Rails.logger.debug "Variants params received: #{variants_params.inspect}"
    Rails.logger.debug "Variants params class: #{variants_params.class}"

    return { 'options' => [], 'variants_pricing' => {} } if variants_params.blank?

    # Get the options data - handle ActionController::Parameters, Hash, and Array
    options_data = nil

    if variants_params.is_a?(ActionController::Parameters) || variants_params.is_a?(Hash)
      options_data = variants_params['options'] || variants_params[:options]
    elsif variants_params.is_a?(Array)
      options_data = variants_params
    else
      Rails.logger.warn "Unexpected variants_params type: #{variants_params.class}"
      return { 'options' => [], 'variants_pricing' => {} }
    end

    return { 'options' => [], 'variants_pricing' => {} } if options_data.blank?

    options = []

    # Convert hash with numeric keys to array (Rails form behavior)
    # Both ActionController::Parameters and Hash respond to keys/values
    options_array = if options_data.respond_to?(:keys)
                      # Sort by keys to maintain order when converting hash to array
                      options_data.keys.sort.map { |k| options_data[k] }
                    else
                      options_data
                    end

    options_array.each do |option_data|
      next unless option_data.respond_to?(:[]) # Skip if not hash-like

      # Handle both string and symbol keys
      option_name = option_data['name'] || option_data[:name]
      option_values = option_data['values'] || option_data[:values]

      # Skip empty options
      next if option_name.blank?

      # Ensure option_values is an array and filter out blank values
      values_array = case option_values
                     when Array
                       option_values
                     else
                       # Handle case where values might be a hash (though it shouldn't be in this case)
                       if option_values.respond_to?(:keys)
                         option_values.keys.sort.map { |k| option_values[k] }
                       else
                         []
                       end
                     end

      # Filter out blank values
      values = values_array.reject(&:blank?)
      next if values.empty?

      options << {
        'name' => option_name.strip,
        'values' => values.map(&:strip)
      }
    end

    # Process variant pricing data
    variants_pricing = {}

    # Get combinations, prices, quantities, SKUs, and images arrays
    combinations = variants_params['combinations'] || variants_params[:combinations] || []
    prices = variants_params['prices'] || variants_params[:prices] || []
    quantities = variants_params['quantities'] || variants_params[:quantities] || []
    skus = variants_params['skus'] || variants_params[:skus] || []

    # Handle variant images from params directly (not through product_params due to file handling)
    variant_images = params[:product] && params[:product][:variants] && params[:product][:variants][:images] ?
                       params[:product][:variants][:images] : []

    Rails.logger.debug "Combinations: #{combinations.inspect}"
    Rails.logger.debug "Prices: #{prices.inspect}"
    Rails.logger.debug "Quantities: #{quantities.inspect}"
    Rails.logger.debug "SKUs: #{skus.inspect}"
    Rails.logger.debug "Variant Images: #{variant_images.length} files"

    # Process each combination to create the variants_pricing structure
    combinations.each_with_index do |combination_json, index|
      next if combination_json.blank?

      begin
        # Parse the JSON combination
        combination = JSON.parse(combination_json)

        # Create variant key from combination values (e.g., "red_small")
        variant_key = combination.map { |c| c['value'].downcase.gsub(/\s+/, '_') }.join('_')

        # Get corresponding price, quantity, and SKU
        price = prices[index].present? ? prices[index].to_f : 0.0
        quantity = quantities[index].present? ? quantities[index].to_i : 0
        sku = skus[index].present? ? skus[index].strip : ''

        # Handle variant image upload
        image_url = ''
        variant_image = variant_images[index] if variant_images[index].present?

        if variant_image && variant_image.respond_to?(:original_filename) && variant_image.original_filename.present?
          # Upload variant image to Active Storage
          current_user.website.product_images.attach(
            io: variant_image,
            filename: variant_image.original_filename,
            content_type: variant_image.content_type,
            metadata: {
              product_id: @product_id,
              variant_key: variant_key,
              variant_type: 'variant'
            }
          )

          # Get the URL for the attached image
          image_url = Rails.application.routes.url_helpers.rails_blob_url(
            current_user.website.product_images.last,
            only_path: true
          )
        end

        variants_pricing[variant_key] = {
          'price' => price,
          'quantity' => quantity,
          'sku' => sku,
          'image' => image_url
        }

      rescue JSON::ParserError => e
        Rails.logger.error "Error parsing combination JSON: #{e.message} - #{combination_json}"
        next
      end
    end

    result = {
      'options' => options,
      'variants_pricing' => variants_pricing
    }
    Rails.logger.debug "Parsed variants result: #{result.inspect}"
    result
  rescue => e
    Rails.logger.error "Error parsing variants data: #{e.message}"
    Rails.logger.error "Variants params: #{variants_params.inspect}"
    Rails.logger.error "Backtrace: #{e.backtrace.first(5).join('\n')}"
    { 'options' => [], 'variants_pricing' => {} }
  end

  # Keep the old method for backward compatibility if needed
  def parse_variant_options(variant_text)
    return { 'variants_options' => {}, 'variants_pricing' => {} } if variant_text.blank?

    variants_options = {}
    variant_text.split("\n").each do |line|
      if line.include?(':')
        key, values = line.split(':', 2)
        variants_options[key.strip.downcase] = values.split(',').map(&:strip)
      end
    end

    { 'variants_options' => variants_options, 'variants_pricing' => {} }
  end

  def parse_tags(tags_text)
    return [] if tags_text.blank?
    tags_text.split(',').map(&:strip).reject(&:blank?)
  end

  def find_product
    products = current_user.website&.products || []
    @product = products.find { |p| p['id'] == params[:id] }

    unless @product
      redirect_to manage_website_shop_products_path, alert: 'Product not found!'
    end
  end

  def load_product_images
    if @product
      @product_images = @product['images'] || []
    end
  end

  def handle_image_uploads_and_get_urls(product_id)
    image_urls = []

    # Access images directly from params instead of through product_params
    uploaded_images = params[:product][:images] if params[:product] && params[:product][:images]

    if uploaded_images.present?
      # Filter out empty strings that might come from the form
      uploaded_images.reject(&:blank?).each do |image|
        if image.respond_to?(:original_filename) && image.original_filename.present?
          # Attach to website
          current_user.website.product_images.attach(
            io: image,
            filename: image.original_filename,
            content_type: image.content_type,
            metadata: { product_id: product_id }
          )

          # Get the URL for the attached image
          image_urls << Rails.application.routes.url_helpers.rails_blob_url(
            current_user.website.product_images.last,
            only_path: true
          )
        end
      end
    end

    image_urls
  end

  def remove_product_images_from_storage(image_urls)
    return unless image_urls.is_a?(Array)

    image_urls.each do |url|
      remove_single_image_from_storage(url)
    end
  end

  def remove_single_image_from_storage(image_url)
    return unless image_url.present?

    # Extract blob ID from URL and find the attachment
    blob_id = image_url.split('/').last.split('?').first
    blob = ActiveStorage::Blob.find_by(id: blob_id)
    blob&.purge
  rescue
    # Handle cases where blob might not exist
    Rails.logger.warn "Could not find or remove image with URL: #{image_url}"
  end

  def build_category_options
    return [] unless current_user.website&.categories&.dig('products')

    categories = current_user.website.categories['products']
    options = []

    # First, build a hash of all categories for easy lookup
    category_lookup = {}
    categories.each do |id, category|
      category_lookup[id] = category
    end

    # Build hierarchical options
    categories.each do |id, category|
      # Skip if this category has a parent (we'll handle it in the hierarchy)
      next if category['parent_category'].present?

      # Add top-level category
      options << [category['name'], id]

      # Add child categories with indentation
      add_child_categories(options, category_lookup, id, '  ')
    end

    options
  end

  # Recursive method to add child categories with proper indentation
  def add_child_categories(options, category_lookup, parent_id, indent)
    category_lookup.each do |id, category|
      if category['parent_category'] == parent_id
        options << ["#{indent}#{category['name']}", id]
        # Recursively add children of this category
        add_child_categories(options, category_lookup, id, "#{indent}  ")
      end
    end
  end

  # Get selected categories for the current product
  def selected_categories
    return [] unless @product

    # Assuming categories are stored as an array of IDs in the product data
    @product.dig('data', 'categories') || []
  end

  def parse_categories(categories_string)
    return [] if categories_string.blank?

    category_names = categories_string.split(',').map(&:strip).reject(&:blank?)
    category_ids = []

    # Get current categories or initialize
    current_categories = current_user.website.categories || {}
    current_categories['products'] ||= {}

    category_names.each do |category_name|
      # First, try to find existing category by name (case insensitive)
      existing_category = current_categories['products'].find do |id, cat|
        cat['name'].downcase == category_name.downcase
      end

      if existing_category
        # Category exists, use its ID
        category_ids << existing_category[0] # The key is the ID
      else
        # Category doesn't exist, create it
        new_category_id = SecureRandom.uuid
        slug = category_name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-+|-+$/, '')

        current_categories['products'][new_category_id] = {
          'name' => category_name,
          'slug' => slug,
          'parent_category' => '',
          'description' => '',
          'id' => new_category_id,
          'seo' => {
            'focus_keyword' => '',
            'title_tag' => '',
            'meta_description' => ''
          }
        }

        category_ids << new_category_id
      end
    end

    # Update the website with new categories if any were created
    current_user.website.update(categories: current_categories)

    category_ids
  end

  def parse_images(images_string)
    return [] if images_string.blank?

    # Split by comma if multiple image paths
    images_string.split(',').map(&:strip)
  end

  def parse_boolean(value)
    return true if value.to_s.downcase.in?(['true', '1', 'yes', 'on'])
    return false if value.to_s.downcase.in?(['false', '0', 'no', 'off'])
    false # default
  end

  def parse_variants(variants_string)
    return [] if variants_string.blank?

    # Parse JSON string or comma-separated values
    begin
      JSON.parse(variants_string)
    rescue JSON::ParserError
      variants_string.split(',').map(&:strip)
    end
  end

  def parse_variant_pricing(pricing_string)
    return {} if pricing_string.blank?

    begin
      JSON.parse(pricing_string)
    rescue JSON::ParserError
      {}
    end
  end

  def parse_tags(tags_string)
    return [] if tags_string.blank?

    tags_string.split(',').map(&:strip)
  end

  def generate_url_handle(name)
    return "" if name.blank?

    name.downcase.gsub(/[^a-z0-9]+/, '-').gsub(/^-+|-+$/, '')
  end

  def build_product_data(row)
    # Validate required fields
    raise "Product name is required" if row[:name].blank?

    # Handle image uploads from URLs
    image_urls = handle_csv_image_uploads(row[:images], SecureRandom.uuid)

    {
      "id" => SecureRandom.uuid,
      "data" => {
        "name" => row[:name],
        "description" => row[:description] || "",
        "categories" => parse_categories(row[:categories])
      },
      "images" => image_urls, # This will now contain the Active Storage URLs
      "price" => {
        "price" => row[:price]&.to_f || 0.0,
        "sale_price" => row[:sale_price]&.to_f,
        "cost_per_item" => row[:cost_per_item]&.to_f
      },
      "inventory" => {
        "track_quantity" => parse_boolean(row[:track_quantity]),
        "quantity" => row[:quantity]&.to_i || 0,
        "sell_out_of_stock" => parse_boolean(row[:sell_out_of_stock]),
        "has_sku_or_barcode" => parse_boolean(row[:has_sku_or_barcode]),
        "sku" => row[:sku] || "",
        "barcode" => row[:barcode] || ""
      },
      "shipping" => {
        "physical_product" => parse_boolean(row[:physical_product]),
        "weight" => row[:weight] || "",
        "sizes" => {
          "width" => row[:width] || "",
          "height" => row[:height] || "",
          "depth" => row[:depth] || ""
        }
      },
      "variants" => {
        "options" => parse_variants(row[:variant_options]),
        "variants_pricing" => parse_variant_pricing(row[:variant_pricing])
      },
      "organization" => {
        "product_type" => row[:product_type] || "",
        "vendor" => row[:vendor] || "",
        "tags" => parse_tags(row[:tags])
      },
      "seo" => {
        "focus_keyword" => row[:focus_keyword] || "",
        "title_tag" => row[:title_tag] || row[:name] || "",
        "meta_description" => row[:meta_description] || "",
        "url_handle" => generate_url_handle(row[:name])
      },
      "status" => row[:status] || "active",
      "created_at" => Time.current.iso8601
    }
  end

  def ensure_user_has_website
    unless current_user&.website
      redirect_to manage_setup_path, alert: 'Please complete your website setup first.'
      return false
    end
    true
  end

  def handle_csv_image_uploads(images_string, product_id)
    return [] if images_string.blank?

    image_urls = []
    image_paths = images_string.split(',').map(&:strip)

    image_paths.each do |image_path|
      next if image_path.blank?

      begin
        # Handle different types of image sources
        if image_path.start_with?('http://', 'https://')
          # Download from URL
          image_url = download_and_attach_image_from_url(image_path, product_id)
          image_urls << image_url if image_url.present?
        else
          # Handle local file path (if you want to support this)
          # You could extend this to handle local files if needed
          Rails.logger.warn "Local file paths not supported in CSV import: #{image_path}"
        end
      rescue => e
        Rails.logger.error "Failed to process image #{image_path}: #{e.message}"
        # Continue with other images even if one fails
      end
    end

    image_urls
  end

  def download_and_attach_image_from_url(url, product_id)
    require 'open-uri'

    begin
      # Download the image
      downloaded_image = URI.open(url)

      # Get filename from URL or generate one
      filename = File.basename(URI.parse(url).path)
      filename = "image_#{SecureRandom.hex(8)}.jpg" if filename.blank? || !filename.include?('.')

      # Determine content type
      content_type = case File.extname(filename).downcase
                     when '.jpg', '.jpeg'
                       'image/jpeg'
                     when '.png'
                       'image/png'
                     when '.gif'
                       'image/gif'
                     when '.webp'
                       'image/webp'
                     else
                       'image/jpeg' # default
                     end

      # Attach to website
      current_user.website.product_images.attach(
        io: downloaded_image,
        filename: filename,
        content_type: content_type,
        metadata: {
          product_id: product_id,
          source: 'csv_import'
        }
      )

      # Get the URL for the attached image
      Rails.application.routes.url_helpers.rails_blob_url(
        current_user.website.product_images.last,
        only_path: true
      )

    rescue => e
      Rails.logger.error "Failed to download image from #{url}: #{e.message}"
      nil
    ensure
      downloaded_image&.close if downloaded_image.respond_to?(:close)
    end
  end
end
