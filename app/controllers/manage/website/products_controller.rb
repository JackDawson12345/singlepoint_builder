class Manage::Website::ProductsController < Manage::BaseController
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

    new_product = {
      'id' => product_id,
      'data' => {
        'name' => product_params[:name],
        'description' => product_params[:description],
        'category' => product_params[:category]
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
        'title' => product_params[:seo_title] || '',
        'description' => product_params[:seo_description] || '',
        'url_handle' => product_params[:seo_url] || ''
      },
      'status' => product_params[:status] || 'active',
      'created_at' => Time.current.iso8601
    }

    current_products << new_product

    if current_user.website
      current_user.website.update(products: current_products)
    end

    product_page = current_user.website.pages["theme_pages"]["shop"]

    if product_page.present?
      # Calculate the next position
      next_position = if product_page['inner_pages'].empty?
                        1
                      else
                        product_page['inner_pages'].values.map { |page| page['position'].to_i }.max + 1
                      end

      product_page['inner_pages'][new_product['data']['name']] = {
        "theme_page_id" => new_product['id'],
        "components" => product_page['inner_pages_components'],
        "slug" => new_product['seo']['url_handle'],
        "position" => next_position.to_s
      }

      current_user.website.save

    end

    redirect_to manage_website_products_path, notice: 'Product was successfully created!'
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

      current_products[product_index].merge!({
                                               'data' => {
                                                 'name' => product_params[:name],
                                                 'description' => product_params[:description],
                                                 'category' => product_params[:category]
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

      redirect_to manage_website_products_path, notice: 'Product was successfully updated!'
    else
      redirect_to manage_website_products_path, alert: 'Product not found!'
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
    redirect_to manage_website_products_path, notice: 'Product was successfully deleted!'
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

    redirect_to edit_manage_website_product_path(params[:id])
  end

  def index
    @products = current_user.website&.products || []
  end

  private

  def product_params
    params.require(:product).permit(
      :name, :description, :category, :price, :sale_price, :cost_per_item,
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
      redirect_to manage_website_products_path, alert: 'Product not found!'
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
end