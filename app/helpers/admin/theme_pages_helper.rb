module Admin::ThemePagesHelper

  def render_theme_preview_content(component, theme_page_id = nil, component_page_id)
    componentHTML = component.content['html']
    updated_content = componentHTML

    unless component.editable_fields == ""
      # Get customisations if user_id and theme_page_id are provided
      field_values = component.editable_fields.to_h

      field_values.each do |field_name, field_value|
        updated_content = updated_content.gsub('{{'+field_name.to_s+'}}', field_value.to_s)
      end
    end

    if updated_content.include?('{{nav_items}}')
      unless component.template_patterns == ""
        nav_items_html = render_theme_navbar_items(component)
        updated_content = updated_content.gsub!('{{nav_items}}', nav_items_html)
      end
    end

    updated_content
  end

  def render_theme_preview_css(component, theme)
    componentCSS = component.content['css']
    updated_css_content = componentCSS

    theme_settings = theme.settings

    theme_settings['Colour Scheme'].to_a.each do |name, value|

      if componentCSS.include? '{{' + name + '}}'
        updated_css_content = updated_css_content.gsub!('{{' + name + '}}', value)
      end

    end




    updated_css_content
  end

  private

  def render_theme_navbar_items(component)
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

    pages = {
      "Home" => "#",
      "About Us" => "#",
      "Services" => "#",
      "Contact Us" => "#"
    }

    pages.map do |page_name, page_data|
      pageName = page_name
      pageSlug = page_data

      item_html = nav_template.dup

      # Replace nav_item with page_type
      item_html.gsub!('{{nav_item}}', pageName)

      link = '/manage/website/editor/' + pageSlug

      item_html.gsub!('{{nav_item_link}}', link)
      item_html
    end.join("\n")
  end


end
