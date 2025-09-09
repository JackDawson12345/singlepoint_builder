module Manage::Editor::WebsiteEditorHelper

  def render_editor_content(component, user_id = nil, theme_page_id = nil, component_page_id)
    componentHTML = component.content['html']
    updated_content = componentHTML

    unless component.editable_fields == ""
      # Get customisations if user_id and theme_page_id are provided
      field_values = get_component_field_values(component, user_id, theme_page_id, component_page_id)

      field_values.each do |field_name, field_value|
        updated_content = updated_content.gsub('{{'+field_name.to_s+'}}', field_value.to_s)
      end
    end

    if componentHTML.include?('_class}}')
      class_variables = componentHTML.scan(/\{\{(\w+_class)\}\}/).flatten
      class_values = get_component_class_values(component, user_id, theme_page_id, component_page_id, class_variables)

      class_values.each do |class_value|
        component_value = class_value.split("_")[2..-1].join("_")
        updated_content = updated_content.gsub('{{'+component_value.to_s+'_class}}', class_value.to_s)
      end

    end

    if updated_content.include?('{{nav_items}}')
      unless component.template_patterns == ""
        nav_items_html = render_navbar_items(component)
        updated_content = updated_content.gsub!('{{nav_items}}', nav_items_html)
      end
    end

    if updated_content.include?('{{service_items}}')
      unless component.template_patterns == ""
        service_items_html = render_service_items(component)
        updated_content = updated_content.gsub!('{{service_items}}', service_items_html)
      end
    end

    if updated_content.include?('{{product_items}}')
      unless component.template_patterns == ""
        service_items_html = render_product_items(component)
        updated_content = updated_content.gsub!('{{product_items}}', service_items_html)
      end
    end

    if component.component_type == 'Service Inner'
      service = current_user.website.services.find { |s| s["id"] == theme_page_id }
      updated_content = updated_content.gsub!('{{service_title}}', service['name'])
      updated_content = updated_content.gsub!('{{service_content}}', simple_format(service['content']))
      updated_content = updated_content.gsub!('{{service_image}}', service['featured_image'])
    elsif component.component_type == 'Blog Inner'

    elsif component.component_type == 'Product Inner'

          pages = current_user.website.pages
          theme_page_id = "5622a296-72e7-4d3e-99c4-cd72a9180502"

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

          product = current_user.website.products.find { |s| s["id"] == theme_page_id }

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

  def render_editor_css(component, user_id)
    componentCSS = component.content['css']
    updated_css_content = componentCSS

    user = User.find(user_id)
    website = user.website

    website_settings = website.settings

    website_settings['Colour Scheme'].to_a.each do |name, value|

      if componentCSS.include? '{{' + name.to_s + '}}'
        updated_css_content = updated_css_content.gsub!('{{' + name.to_s + '}}', value.to_s)
      end

    end




    updated_css_content
  end

  def render_preview_css(component, user_id)
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

  def render_preview_content(component, user_id = nil, theme_page_id = nil, component_page_id)
    componentHTML = component.content['html']
    updated_content = componentHTML

    unless component.editable_fields == ""
      # Get customisations if user_id and theme_page_id are provided
      field_values = get_component_field_values(component, user_id, theme_page_id, component_page_id)

      field_values.each do |field_name, field_value|
        updated_content = updated_content.gsub('{{'+field_name.to_s+'}}', field_value.to_s)
      end
    end

    if updated_content.include?('{{nav_items}}')
      unless component.template_patterns == ""
        nav_items_html = render_navbar_items(component)
        updated_content = updated_content.gsub!('{{nav_items}}', nav_items_html)
      end
    end

    if updated_content.include?('{{service_items}}')
      unless component.template_patterns == ""
        service_items_html = render_service_items(component)
        updated_content = updated_content.gsub!('{{service_items}}', service_items_html)
      end
    end

    if updated_content.include?('{{product_items}}')
      unless component.template_patterns == ""
        service_items_html = render_product_items(component)
        updated_content = updated_content.gsub!('{{product_items}}', service_items_html)
      end
    end

    if component.component_type == 'Service Inner'
      service = current_user.website.services.find { |s| s["id"] == theme_page_id }
      updated_content = updated_content.gsub!('{{service_title}}', service['name'])
      updated_content = updated_content.gsub!('{{service_content}}', simple_format(service['content']))
      updated_content = updated_content.gsub!('{{service_image}}', service['featured_image'])
    elsif component.component_type == 'Blog Inner'

    elsif component.component_type == 'Product Inner'

      pages = current_user.website.pages
      theme_page_id = "5622a296-72e7-4d3e-99c4-cd72a9180502"

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

      product = current_user.website.products.find { |s| s["id"] == theme_page_id }

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
  private

  def get_component_field_values(component, user_id, theme_page_id, component_page_id)
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

  def get_component_class_values(component, user_id, theme_page_id, component_page_id, class_variables)

    # Start with default values
    field_values = class_variables
    new_classes = []

    # Override with customisations if they exist
    if user_id && theme_page_id
      user = User.find(user_id)

      field_values.each do |class_value|

        value = class_value.gsub("_class", "")
        new_classes << theme_page_id + '_' + component_page_id + '_' + value

      end
    end

    new_classes
  end

  def render_navbar_items(component)
    raw_template = component.template_patterns

    # Extract the HTML template from the malformed JSON manually
    # Look for the pattern between the first \" after "nav_items": and the last \"
    if match = raw_template.match(/"nav_items":\s*"(.+)"\s*}/)
      # Unescape the basic escapes but keep the template placeholders
      nav_template = match[1].gsub('\\"', '"')
    else
      # Fallback to the whole string if pattern doesn't match
      nav_template = raw_template
    end

    current_user.website.pages["theme_pages"].map do |page_name, page_data|
      pageName = page_name.to_s
      pageSlug = page_data['slug'].to_s

      item_html = nav_template.dup

      # Replace nav_item with page_type
      item_html.gsub!('{{nav_item}}', pageName)

      if controller_name == "preview"
        if pageSlug == '/'
          link = '/manage/website/preview/'
        else
          link = '/manage/website/preview/' + pageSlug
        end
      elsif controller_name == "website_editor"
        if pageSlug == '/'
          link = '/manage/website/editor/'
        else
          link = '/manage/website/editor/' + pageSlug
        end
      end

      item_html.gsub!('{{nav_item_link}}', link)
      item_html
    end.join("\n")
  end

  def render_service_items(component)
    raw_template = component.template_patterns

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

    unless current_user.website.services.blank?
      current_user.website.services.map do |service|

        # Use service attributes instead of undefined page variables
        service_name = service['name'].to_s  # or whatever attribute holds the service name
        service_slug = service['slug'].to_s  # or whatever attribute holds the service slug

        item_html = service_template.dup

        # Replace service template placeholders with actual service data
        item_html.gsub!('{{service_title}}', service_name)
        item_html.gsub!('{{service_excerpt}}', service['excerpt'].to_s) # or service.description
        item_html.gsub!('{{service_image}}', service['featured_image'].to_s) # or whatever holds the image

        service_page = current_user.website.pages["theme_pages"]["services"]
        # Build the service link
        if controller_name == "preview"
          if service_page['slug'].present?
            link = '/manage/website/preview/' + service_page['slug'] + '/' + service_slug
          else
            link = '/manage/website/preview/' + service_slug
          end
        elsif controller_name == "website_editor"
          if service_page['slug'].present?
            link = '/manage/website/editor/' + service_page['slug'] + '/' + service_slug
          else
            link = '/manage/website/editor/' + service_slug
          end
        end

        item_html.gsub!('{{service_link}}', link)
        item_html
      end.join("\n")
    else
      item_html = '<p style="text-align: center;">No Service Found</p>'
      item_html
    end


  end

  def render_product_items(component)
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

    unless current_user.website.products.blank?
      current_user.website.products.map do |service|

        # Use service attributes instead of undefined page variables
        product_name = service['data']['name'].to_s  # or whatever attribute holds the service name
        product_slug = service['seo']['url_handle'].to_s  # or whatever attribute holds the service slug
        product_description = service['data']['description'].to_s
        product_price =service['price']['price'].to_s

        item_html = product_template.dup

        # Replace service template placeholders with actual service data
        item_html.gsub!('{{product_name}}', product_name)
        item_html.gsub!('{{product_excerpt}}', product_description.truncate(50)) # or service.description
        item_html.gsub!('{{product_image}}', service['images'].first) # or whatever holds the image
        item_html.gsub!('{{product_image_alt}}', product_name)
        item_html.gsub!('{{product_price}}', product_price)
        item_html.gsub!('{{rating_count}}', '8')

        service_page = current_user.website.pages["theme_pages"]["services"]
        # Build the service link
        if controller_name == "preview"
          if service['seo']['url_handle'].present?
            link = '/manage/website/preview/' + params['page_slug'] + '/' + product_slug
          else
            link = '/manage/website/preview/' + params['page_slug']
          end
        elsif controller_name == "website_editor"
          if service['seo']['url_handle'].present?
            link = '/manage/website/editor/' + params['page_slug'] + '/' + product_slug
          else
            link = '/manage/website/editor/' + params['page_slug']
          end
        end

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

end