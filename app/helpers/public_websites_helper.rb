module PublicWebsitesHelper

  def render_show_content(component, user_id = nil, theme_page_id = nil, component_page_id)
    componentHTML = component.content['html']
    updated_content = componentHTML

    user = User.find(user_id)

    updated_content = render_global_changes(user, component, updated_content)

    unless component.editable_fields == ""
      # Get customisations if user_id and theme_page_id are provided
      field_values = get_show_component_field_values(component, user_id, theme_page_id, component_page_id)

      field_values.each do |field_name, field_value|
        updated_content = updated_content.gsub('{{'+field_name.to_s+'}}', field_value.to_s)
      end
    end

    if updated_content.include?('{{nav_items}}')
      unless component.template_patterns == ""
        nav_items_html = render_navbar_items(component, user)
        updated_content = updated_content.gsub!('{{nav_items}}', nav_items_html)
      end
    end

    if updated_content.include?('{{service_items}}')
      unless component.template_patterns == ""
        service_items_html = render_show_service_items(component, user_id)
        updated_content = updated_content.gsub!('{{service_items}}', service_items_html)
      end
    end

    if updated_content.include?('{{product_items}}')
      unless component.template_patterns == ""
        service_items_html = render_product_items(component, user_id)
        updated_content = updated_content.gsub!('{{product_items}}', service_items_html)
      end
    end

    if component.component_type == 'Service Inner'
      service = user.website.services.find { |s| s["id"] == theme_page_id }
      updated_content = updated_content.gsub!('{{service_title}}', service['name'])
      updated_content = updated_content.gsub!('{{service_content}}', simple_format(service['content']))
      updated_content = updated_content.gsub!('{{service_image}}', service['featured_image'])
    elsif component.component_type == 'Blog Inner'

    elsif component.component_type == 'Product Inner'

      pages = user.website.pages

      main_page = nil

      pages["theme_pages"].each do |page_name, page_data|
        # Check if it's a main page
        if page_data["theme_page_id"] == theme_page_id
          main_page = page_name
          break
        end

        # Check if it's in inner_pages
        if page_data["inner_pages"].present?
          page_data["inner_pages"].each do |inner_page_name, inner_page_data|
            if inner_page_data["theme_page_id"] == theme_page_id
              main_page = page_name  # This will be "shop" in your case
              break
            end
          end
        end

        break if main_page
      end

      product = user.website.products.find { |s| s["id"] == theme_page_id }

      updated_content = updated_content.gsub!('{{service_page_name}}', main_page)

      updated_content = updated_content.gsub!('{{product_name}}', product['data']['name'])
      updated_content = updated_content.gsub!('{{product_description}}', product['data']['description'])
      updated_content = updated_content.gsub!('{{review_count}}', '10')

      updated_content = updated_content.gsub!('{{product_category}}', product['data']['category'])
      updated_content = updated_content.gsub!('{{product_sku}}', product['inventory']['sku'])
      updated_content = updated_content.gsub!('{{product_weight}}', product['shipping']['weight'])
      updated_content = updated_content.gsub!('{{product_width}}', product['shipping']['sizes']['width'])
      updated_content = updated_content.gsub!('{{product_height}}', product['shipping']['sizes']['height'])
      updated_content = updated_content.gsub!('{{product_depth}}', product['shipping']['sizes']['depth'])

      updated_content = updated_content.gsub!('{{product_main_image}}', product['images'].first)

      render_product_price = render_product_price(component, product['price']['price'], product['price']['sale_price'])
      updated_content = updated_content.gsub!('{{product_price}}', render_product_price)

      render_product_images = render_product_images(component, product)
      updated_content = updated_content.gsub!('{{product_images}}', render_product_images)

    end

    updated_content
  end

  def render_show_css(component, user_id)
    componentCSS = component.content['css']
    updated_css_content = componentCSS

    user = User.find(user_id)
    website = user.website

    website_settings = website.settings

    website_settings['Colour Scheme'].to_a.each do |name, value|

      if componentCSS.include? '{{' + name + '}}'
        updated_css_content = updated_css_content.gsub!('{{' + name + '}}', value)
      end

    end

    updated_css_content
  end
  private

  def get_show_component_field_values(component, user_id, theme_page_id, component_page_id)
    # Start with default values
    field_values = component.editable_fields.to_h

    # Override with customisations if they exist
    if user_id && theme_page_id
      user = User.find(user_id)
      customisations = user.website&.customisations&.dig("customisations") || []

      customisations.each do |customisation|
        if customisation["component_id"] == component.id.to_s &&
           customisation["theme_page_id"] == theme_page_id.to_s && customisation['component_page_id'] == component_page_id
          field_values[customisation["field_name"]] = customisation["field_value"]
        end
      end
    end

    field_values
  end


  def render_navbar_items(component, user)
    # Handle both Hash and JSON string formats
    if component.template_patterns.is_a?(Hash)
      nav_template = component.template_patterns["nav_items"]
    elsif component.template_patterns.is_a?(String)
      # Parse JSON string and extract nav_items
      begin
        parsed_patterns = JSON.parse(component.template_patterns)
        nav_template = parsed_patterns["nav_items"]
      rescue JSON::ParserError
        # Fallback to regex if JSON parsing fails
        if match = component.template_patterns.match(/"nav_items":\s*"(.+)"\s*}/)
          nav_template = match[1].gsub('\\"', '"')
        else
          nav_template = nil
        end
      end
    else
      nav_template = nil
    end

    # Return empty string if no template found
    return "" unless nav_template

    user.website.pages["theme_pages"].sort_by { |name, data| data['position'].to_i }.map do |page_name, page_data|
      page_name_str = page_name.to_s
      page_slug = page_data['slug'].to_s

      # Create a copy of the template for this iteration
      item_html = nav_template.dup

      # Replace nav_item placeholder
      item_html.gsub!('{{nav_item}}', page_name_str)

      # Build the link based on controller
      if page_slug == '/'
        link = '/'
      else
        link = '/' + page_slug
      end

      # Replace nav_item_link placeholder
      item_html.gsub!('{{nav_item_link}}', link)

      item_html
    end.join("\n")
  end

  def render_show_service_items(component, user_id)
    raw_template = component.template_patterns

    user = User.find(user_id)

    # Since raw_template is a Hash, access the service_items key directly
    if raw_template.is_a?(Hash) && raw_template["service_items"]
      service_template = raw_template["service_items"]
    elsif raw_template.is_a?(String)
      # Fallback for string format (your original regex approach)
      if match = raw_template.match(/"service_items":\s*"(.+)"\s*}/)
        service_template = match[1].gsub('\\"', '"')
      else
        service_template = raw_template
      end
    else
      service_template = raw_template.to_s
    end

    unless user.website.services.blank?
      user.website.services.map do |service|

        # Use service attributes instead of undefined page variables
        service_name = service['name'].to_s  # or whatever attribute holds the service name
        service_slug = service['slug'].to_s  # or whatever attribute holds the service slug

        item_html = service_template.dup

        # Replace service template placeholders with actual service data
        item_html.gsub!('{{service_title}}', service_name)
        item_html.gsub!('{{service_excerpt}}', service['excerpt'].to_s) # or service.description
        item_html.gsub!('{{service_image}}', service['featured_image'].to_s) # or whatever holds the image

        service_page = user.website.pages["theme_pages"]["services"]
        # Build the service link
        if service_page['slug'].present?
          link = '/' + service_page['slug'] + '/' + service_slug
        else
          link = '/' + service_slug
        end

        item_html.gsub!('{{service_link}}', link)
        item_html
      end.join("\n")
    else
      item_html = '<p style="text-align: center;">No Service Found</p>'
      item_html
    end


  end

  def render_product_items(component, user_id)
    user = User.find(user_id)
    raw_template = component.template_patterns

    # Since raw_template is a Hash, access the service_items key directly
    if raw_template.is_a?(Hash) && raw_template["product_items"]
      product_template = raw_template["product_items"]
    elsif raw_template.is_a?(String)
      # Fallback for string format (your original regex approach)
      if match = raw_template.match(/"product_items":\s*"(.+)"\s*}/)
        product_template = match[1].gsub('\\"', '"')
      else
        product_template = raw_template
      end
    else
      product_template = raw_template.to_s
    end

    unless user.website.products.blank?
      user.website.products.map do |service|

        # Use service attributes instead of undefined page variables
        product_name = service['data']['name'].to_s  # or whatever attribute holds the service name
        product_slug = service['seo']['url_handle'].to_s  # or whatever attribute holds the service slug
        product_description = service['data']['description'].to_s
        product_price = service['price']['price'].to_s

        product_slug = product_slug.gsub(' ', '-')


        item_html = product_template.dup

        # Replace service template placeholders with actual service data
        item_html.gsub!('{{product_name}}', product_name)
        item_html.gsub!('{{product_excerpt}}', product_description.truncate(50)) # or service.description
        item_html.gsub!('{{product_image}}', service['images'].first) # or whatever holds the image
        item_html.gsub!('{{product_image_alt}}', product_name)
        item_html.gsub!('{{product_price}}', product_price)
        item_html.gsub!('{{rating_count}}', '8')

        # Build the service link
        link = '/' + params['page_slug'] + '/' + product_slug

        item_html.gsub!('{{product_link}}', link)
        item_html
      end.join("\n")
    else
      item_html = '<p style="text-align: center;">No Products Found</p>'
      item_html
    end
  end

  def render_product_images(component, product)

    raw_template = component.template_patterns['product_images']

    images = product['images']

    images.map.with_index do |image, index|
      item_html = raw_template.dup

      item_html.gsub!('{{product_image}}', image.to_s)
      item_html.gsub!('{{product_image_count}}', (index + 1).to_s)

      item_html
    end.join("\n")

  end

  def render_product_price(component, price, sale_price)

    unless price.blank? && sale_price.blank?
      raw_template = component.template_patterns['product_price']['sale']
      raw_template.gsub!('{{product_sale_price}}', sprintf('%.2f', sale_price))
      raw_template.gsub!('{{product_price}}', sprintf('%.2f', price))
      raw_template.gsub!('{{product_price_discount}}', (((price - sale_price) / price) * 100).round(0).to_s)
    else
      raw_template = component.template_patterns['product_price']['normal']
    end

    raw_template
  end

  def render_global_changes(user, component, updated_content)
    if updated_content.include?('{{global_logo}}')
      if user.logo.attached?
        logo_url = user.logo.attached? ? url_for(user.logo) : ''
        updated_content = updated_content.gsub('{{global_logo}}', logo_url)
      else
        updated_content = updated_content.gsub('{{global_logo}}', component.editable_fields['global_logo'])
      end
    end
    if updated_content.include?('{{global_phone}}')
      if user['business_info']['phone'].nil?
        updated_content = updated_content.gsub('{{global_phone}}', component.editable_fields['global_phone'])
      else
        updated_content = updated_content.gsub('{{global_phone}}', user['business_info']['phone'])
      end
    end
    if updated_content.include?('{{global_email}}')
      if user['business_info']['email'].nil?
        updated_content = updated_content.gsub('{{global_email}}', component.editable_fields['global_email'])
      else
        updated_content = updated_content.gsub('{{global_email}}', user['business_info']['email'])
      end
    end
    if updated_content.include?('{{global_address}}')
      if user['business_info']['location']['location_name'].nil?
        updated_content = updated_content.gsub('{{global_address}}', component.editable_fields['global_address'])
      else
        updated_content = updated_content.gsub('{{global_address}}', user['business_info']['location']['location_name'])
      end
    end

    if updated_content.include?('{{social_medias}}')
      if user['business_info']['social_media'].nil?
        updated_content = updated_content.gsub('{{global_address}}', component.editable_fields['global_address'])
      else
        social_media_html = render_social_media_items(component, user)
        updated_content = updated_content.gsub!('{{social_medias}}', social_media_html)
      end
    end

    updated_content
  end

  def render_social_media_items(component, user)
    if component.template_patterns.is_a?(Hash)
      social_template = component.template_patterns["social_medias"]
    elsif component.template_patterns.is_a?(String)
      # Parse JSON string and extract social_medias
      begin
        parsed_patterns = JSON.parse(component.template_patterns)
        social_template = parsed_patterns["social_medias"]
      rescue JSON::ParserError
        # Fallback to regex if JSON parsing fails
        if match = component.template_patterns.match(/"social_medias":\s*"(.+)"\s*}/)
          social_template = match[1].gsub('\\"', '"')
        else
          social_template = nil
        end
      end
    else
      social_template = nil
    end

    # Return empty string if no template found
    return "" unless social_template

    user['business_info']['social_media'].map do |name, data|

      # Create a copy of the template for this iteration
      item_html = social_template.dup

      # Replace nav_item placeholder
      item_html.gsub!('{{social_icon}}', '<i class="' + data['icon'] + '"></i>')
      item_html.gsub!('{{social_link}}', data['link'])

      item_html
    end.join("\n")
  end
end
