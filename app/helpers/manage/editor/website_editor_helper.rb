module Manage::Editor::WebsiteEditorHelper

  require 'nokogiri'

  def render_editor_content(component, user_id = nil, theme_page_id = nil, component_page_id)
    componentHTML = component.content['html']
    updated_content = componentHTML

    updated_content = render_global_changes(current_user, component, updated_content)

    unless component.editable_fields == ""
      result = render_custom_styles(current_user.id, component, theme_page_id, component_page_id)
      field_values = result[:field_values]
      customisations = result[:customisations]

      # FIRST: Handle class replacements before styling
      if componentHTML.include?('_class}}')
        class_variables = componentHTML.scan(/\{\{(\w+_class)\}\}/).flatten
        class_values = get_component_class_values(component, user_id, theme_page_id, component_page_id, class_variables)

        class_values.each do |class_value|
          component_value = class_value.split("_")[2..-1].join("_")
          updated_content = updated_content.gsub('{{'+component_value.to_s+'_class}}', class_value.to_s)
        end
      end

      # SECOND: Replace all field values
      field_values.each do |field_name, field_value|
        if field_value.is_a?(Hash)
          field_value.each do |sub_key, sub_value|
            byebug
            updated_content = updated_content.gsub("{{#{sub_key}}}", sub_value.to_s)
          end
        else
          # Check if the field value contains HTML that matches the container
          clean_value = field_value.to_s
          if clean_value.match?(/^<p>(.*)<\/p>$/m) && updated_content.include?("<p class=\"#{theme_page_id}_#{component_page_id}_#{field_name}")
            # Extract content from p tags if we're inserting into a p tag
            clean_value = clean_value.gsub(/^<p>(.*)<\/p>$/m, '\1')
          end
          updated_content = updated_content.gsub("{{#{field_name}}}", clean_value)
        end
      end

      # THIRD: Apply styling to the resolved class names
      if customisations && customisations.any?
        customisations.each do |customisation|
          field_name = customisation['field_name']
          field_styling = customisation['field_styling']

          next if field_styling.empty?

          # Use the actual resolved class name (UUID format)
          resolved_class_name = "#{theme_page_id}_#{component_page_id}_#{field_name}"

          # Build the style string
          style_pairs = []
          field_styling.each do |key, value|
            style_pairs << "#{key}: #{value}"
          end
          style_string = style_pairs.join('; ')

          # Find elements with the resolved class name and add styling
          pattern = /class="([^"]*#{Regexp.escape(resolved_class_name)}[^"]*)"/
          updated_content = updated_content.gsub(pattern) do |match|
            existing_classes = $1
            "class=\"#{existing_classes}\" style=\"#{style_string}\""
          end

          puts "Applied styling for #{field_name} to class #{resolved_class_name}: #{style_string}"
        end
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
      updated_content = updated_content.gsub!('{{service_excerpt}}', service['excerpt'])
    elsif component.component_type == 'Blog Inner'

    elsif component.component_type == 'Product Inner'

          pages = current_user.website.pages

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

  def render_editor_theme_css(user_id)
    user = User.find(user_id)
    theme = user.website.theme
    global_css = user.website.theme.global_css

    if global_css.include?('{{primary_colour}}')
      global_css = global_css.gsub('{{primary_colour}}', user.website.settings['Colour Scheme']['primary_colour'])
    end
    if global_css.include?('{{secondary_colour}}')
      global_css = global_css.gsub('{{secondary_colour}}', user.website.settings['Colour Scheme']['secondary_colour'])
    end

  end

  def render_edit_field_button(html_content)
    doc = Nokogiri::HTML::DocumentFragment.parse(html_content)

    doc.css('.editable-field').each do |element|
      unless element['onclick']
        classes = element['class'].split(' ')

        target_class = classes.find do |cls|
          cls != 'editable-field' && cls.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}_\w+\z/)
        end

        onclick_value = target_class ? "showEditorFields('#{target_class}')" : 'showEditorFields()'

        # If current element is empty and has a next sibling with content, move onclick there
        if element.content.strip.empty? && element.next_sibling&.name == element.name
          element.next_sibling['onclick'] = onclick_value
        else
          element['onclick'] = onclick_value
        end
      end
    end

    doc.to_html.html_safe
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

  def render_preview_theme_css(user_id)
    user = User.find(user_id)
    theme = user.website.theme
    global_css = user.website.theme.global_css

    if global_css.include?('{{primary_colour}}')
      global_css = global_css.gsub('{{primary_colour}}', user.website.settings['Colour Scheme']['primary_colour'])
    end
    if global_css.include?('{{secondary_colour}}')
      global_css = global_css.gsub('{{secondary_colour}}', user.website.settings['Colour Scheme']['secondary_colour'])
    end

  end

  def render_preview_content(component, user_id = nil, theme_page_id = nil, component_page_id)
    componentHTML = component.content['html']
    updated_content = componentHTML

    updated_content = render_global_changes(current_user, component, updated_content)

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
      updated_content = updated_content.gsub!('{{service_excerpt}}', service['excerpt'])

      global_number = current_user['business_info']['phone'] || '01234 567890'
      updated_content = updated_content.gsub!('{{global_number}}', global_number)

      service_links_html = render_service_inner_items(component, service)
      updated_content = updated_content.gsub!('{{service_links}}', service_links_html)

    elsif component.component_type == 'Blog Inner'

    elsif component.component_type == 'Product Inner'

      pages = current_user.website.pages

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

  def scope_css_to_selector(css, scope_selector)
    return '' if css.blank?

    # Clean up the CSS and split into manageable chunks
    cleaned_css = css.gsub(/\/\*.*?\*\//m, '').strip

    # Split by closing braces to get individual rules
    rules = cleaned_css.split(/(?<=\})\s*/)

    scoped_rules = rules.map do |rule|
      rule = rule.strip
      next if rule.empty?

      # Handle different types of CSS rules
      case rule
      when /^@media/
        # Media queries - scope the content inside
        scope_media_query(rule, scope_selector)
      when /^@keyframes/, /^@font-face/, /^@import/, /^@charset/
        # These should remain unscoped
        rule
      when /^:root\s*\{/
        # CSS custom properties should remain unscoped at root level
        rule
      else
        # Regular CSS rules - scope the selectors
        scope_regular_rule(rule, scope_selector)
      end
    end

    scoped_rules.compact.join("\n")
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

    current_user.website.pages["theme_pages"].sort_by { |name, data| data['position'].to_i }.map do |page_name, page_data|
      page_name_str = page_name.to_s
      page_slug = page_data['slug'].to_s

      # Create a copy of the template for this iteration
      item_html = nav_template.dup

      # Replace nav_item placeholder
      item_html.gsub!('{{nav_item}}', page_name_str)

      # Build the link based on controller
      if controller_name == "preview"
        link = page_slug == '/' ? '/manage/website/preview/' : '/manage/website/preview/' + page_slug
      elsif controller_name == "website_editor"
        link = page_slug == '/' ? '/manage/website/editor/' : '/manage/website/editor/' + page_slug
      end

      # Replace nav_item_link placeholder
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
      current_user.website.services.map.with_index do |service, index|

        # Use service attributes instead of undefined page variables
        service_name = service['name'].to_s  # or whatever attribute holds the service name
        service_slug = service['slug'].to_s  # or whatever attribute holds the service slug

        item_html = service_template.dup

        # Replace service template placeholders with actual service data
        item_html.gsub!('{{service_title}}', service_name)
        item_html.gsub!('{{service_excerpt}}', service['excerpt'].to_s) # or service.description
        item_html.gsub!('{{service_icon}}', service['icon'].to_s) # or whatever holds the image
        item_html.gsub!('{{service_image}}', service['featured_image'].to_s) # or whatever holds the image
        item_html.gsub!('{{service_number}}', '0' + (index + 1).to_s) # or whatever holds the image

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

  def scope_regular_rule(rule, scope_selector)
    # Match selector(s) and declaration block
    if rule.match(/^([^{]+)\s*\{([^}]*)\}(.*)$/m)
      selectors = $1.strip
      declarations = $2.strip
      remainder = $3.strip

      return rule if declarations.empty?

      # Split multiple selectors and scope each one
      selector_list = selectors.split(',').map(&:strip)

      scoped_selectors = selector_list.map do |selector|
        scope_single_selector(selector, scope_selector)
      end

      result = "#{scoped_selectors.join(', ')} { #{declarations} }"
      result += remainder if remainder.present?
      result
    else
      rule
    end
  end

  def scope_single_selector(selector, scope_selector)
    # Handle pseudo-selectors and special cases
    case selector
    when /^\s*html\b/, /^\s*body\b/
      # Replace html/body with the scope selector
      selector.gsub(/^\s*(html|body)\b/, scope_selector)
    when /^\s*\*/
      # Universal selector - scope it
      selector.gsub(/^\s*\*/, "#{scope_selector} *")
    when /^:/
      # Pseudo-classes that should apply to the scope itself
      "#{scope_selector}#{selector}"
    else
      # Regular selectors - prepend scope
      "#{scope_selector} #{selector}"
    end
  end

  def scope_media_query(rule, scope_selector)
    # Extract media query and its contents
    if rule.match(/^(@media[^{]+)\{(.+)\}$/m)
      media_declaration = $1
      media_content = $2

      # Recursively scope the content inside the media query
      scoped_content = scope_css_to_selector(media_content, scope_selector)

      "#{media_declaration} {\n#{scoped_content}\n}"
    else
      rule
    end
  end

  def render_global_changes(user_id, component, updated_content)
    if updated_content.include?('{{global_logo}}')
      if current_user.logo.attached?
        logo_url = current_user.logo.attached? ? url_for(current_user.logo) : ''
        updated_content = updated_content.gsub('{{global_logo}}', logo_url)
      else
        updated_content = updated_content.gsub('{{global_logo}}', component.editable_fields['global_logo'])
      end
    end
    if updated_content.include?('{{global_phone}}')
      if current_user['business_info']['phone'].nil?
        updated_content = updated_content.gsub('{{global_phone}}', component.editable_fields['global_phone'])
      else
        updated_content = updated_content.gsub('{{global_phone}}', current_user['business_info']['phone'])
      end
    end
    if updated_content.include?('{{global_email}}')
      if current_user['business_info']['email'].nil?
        updated_content = updated_content.gsub('{{global_email}}', component.editable_fields['global_email'])
      else
        updated_content = updated_content.gsub('{{global_email}}', current_user['business_info']['email'])
      end
    end
    if updated_content.include?('{{global_address}}')
      if current_user['business_info']['location']['location_name'].nil?
        updated_content = updated_content.gsub('{{global_address}}', component.editable_fields['global_address'])
      else
        updated_content = updated_content.gsub('{{global_address}}', current_user['business_info']['location']['location_name'])
      end
    end

    if updated_content.include?('{{social_medias}}')
      if current_user['business_info']['social_media'].nil?
        updated_content = updated_content.gsub('{{global_address}}', component.editable_fields['global_address'])
      else
        social_media_html = render_social_media_items(component)
        updated_content = updated_content.gsub!('{{social_medias}}', social_media_html)
      end
    end

    updated_content
  end

  def render_social_media_items(component)
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

    current_user['business_info']['social_media'].map do |name, data|

      # Create a copy of the template for this iteration
      item_html = social_template.dup

      # Replace nav_item placeholder
      item_html.gsub!('{{social_icon}}', '<i class="' + data['icon'] + '"></i>')
      item_html.gsub!('{{social_link}}', data['link'])

      item_html
    end.join("\n")
  end

  def render_service_inner_items(component, service)
    if component.template_patterns.is_a?(Hash)
      services_template = component.template_patterns["service_links"]
    elsif component.template_patterns.is_a?(String)
      # Parse JSON string and extract service_links
      begin
        parsed_patterns = JSON.parse(component.template_patterns)
        services_template = parsed_patterns["service_links"]
      rescue JSON::ParserError
        # Fallback to regex if JSON parsing fails
        if match = component.template_patterns.match(/"service_links":\s*"(.+)"\s*}/)
          services_template = match[1].gsub('\\"', '"')
        else
          services_template = nil
        end
      end
    else
      services_template = nil
    end

    # Return empty string if no template found
    return "" unless services_template

    current_user.website['services'].map do |data|

      # Create a copy of the template for this iteration
      item_html = services_template.dup

      if controller_name == "preview"
        link = data['slug'] == '/' ? '/manage/website/preview/services/' : '/manage/website/preview/services/' + data['slug']
      elsif controller_name == "website_editor"
        link = data['slug'] == '/' ? '/manage/website/editor/services/' : '/manage/website/editor/services/' + data['slug']
      end

      # Replace nav_item placeholder
      item_html.gsub!('{{service_name}}', data['name'] )
      item_html.gsub!('{{service_link}}', link)

      item_html
    end.join("\n")
  end

  def render_custom_styles(user_id, component, theme_page_id, component_page_id)
    # Start with default values
    field_values = component.editable_fields.to_h
    customisations = []

    # Override with customisations if they exist
    if user_id && theme_page_id
      user = User.find(user_id)
      user_customisations = user.website&.customisations&.dig("customisations") || []

      user_customisations.each do |customisation|
        if customisation["component_id"] == component.id.to_s &&
           customisation["theme_page_id"] == theme_page_id.to_s &&
           customisation['component_page_id'] == component_page_id

          field_values[customisation["field_name"]] = customisation["field_value"]

          # Add this customisation to our array with converted styling
          if customisation['field_styling'].present?
            styling = customisation['field_styling']
            converted_customisation = {
              "field_name" => customisation["field_name"],
              "component_id" => customisation['component_id'],
              "component_page_id" => customisation['component_page_id'],
              "theme_page_id" => customisation['theme_page_id'],
              "field_styling" => {
                "text-align" => styling['alignment'],
                "color" => styling['text_colour'],
                "font-size" => styling['font_size'],
                "font-weight" => styling['font_weight'],
                "text-transform" => styling['font_transform'],
                "font-style" => styling['font_style'],
                "text-decoration" => styling['font_decoration'],
                "line-height" => styling['line_height'],
                "letter-spacing" => styling['letter_spacing'],
                "word-spacing" => styling['word_spacing']
              }
            }
            customisations << converted_customisation
          end
        end
      end
    end

    {
      field_values: field_values,
      customisations: customisations  # Return the array instead of single field_styling
    }
  end

end