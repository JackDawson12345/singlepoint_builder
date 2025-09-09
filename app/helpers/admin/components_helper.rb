module Admin::ComponentsHelper

  def render_component_preview(component)
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
        nav_items_html = render_component_navbar_items(component)
        updated_content = updated_content.gsub!('{{nav_items}}', nav_items_html)
      end
    end

    if updated_content.include?('{{product_items}}')
      unless component.template_patterns == ""
        service_items_html = render_show_product_items(component)
        updated_content = updated_content.gsub!('{{product_items}}', service_items_html)
      end
    end

    updated_content
  end

  def render_sign_up_preview(component)
    componentHTML = component.content['html']

    begin
      # Set up variables that might be needed
      resource = User.new
      resource_name = :user

      # Process the ERB template
      erb_template = ERB.new(componentHTML)
      updated_content = erb_template.result(binding)
    rescue SyntaxError, NameError => e
      # If ERB processing fails, return sanitized version for preview
      updated_content = sanitize_erb_for_preview(componentHTML)
    end

    updated_content
  end

  def render_sign_up_preview(component)
    componentHTML = component.content['html']

    begin
      # Set up variables that might be needed
      resource = User.new
      resource_name = :user

      # Process the ERB template
      erb_template = ERB.new(componentHTML)
      updated_content = erb_template.result(binding)
    rescue SyntaxError, NameError => e
      # If ERB processing fails, convert ERB to static HTML
      updated_content = convert_erb_to_static_html(componentHTML)
    end

    updated_content
  end

  private

  def convert_erb_to_static_html(html_content)
    # Clean up line breaks first
    cleaned_content = html_content.gsub('\r\n', "\n")

    # Convert form_with to regular form tag
    cleaned_content = cleaned_content.gsub(/<%=\s*form_with\([^%]*\)\s*do\s*\|[^%]*\|\s*%>/, '<form action="#" method="post">')

    # Convert form end block
    cleaned_content = cleaned_content.gsub(/<%\s*end\s*%>/, '</form>')

    # Convert form field helpers to HTML inputs
    cleaned_content = convert_form_fields(cleaned_content)

    # Remove any remaining ERB tags
    cleaned_content = cleaned_content.gsub(/<%=?[^%]*%>/, '')

    cleaned_content.html_safe
  end

  def convert_form_fields(content)
    # Convert email fields
    content = content.gsub(/<%=\s*form\.email_field\s*:(\w+)[^%]*%>/) do |match|
      field_name = $1
      placeholder = extract_placeholder(match)
      css_class = extract_css_class(match)
      "<input type=\"email\" name=\"#{field_name}\" class=\"#{css_class}\" placeholder=\"#{placeholder}\">"
    end

    # Convert text fields
    content = content.gsub(/<%=\s*form\.text_field\s*:(\w+)[^%]*%>/) do |match|
      field_name = $1
      placeholder = extract_placeholder(match)
      css_class = extract_css_class(match)
      "<input type=\"text\" name=\"#{field_name}\" class=\"#{css_class}\" placeholder=\"#{placeholder}\">"
    end

    # Convert password fields
    content = content.gsub(/<%=\s*form\.password_field\s*:(\w+)[^%]*%>/) do |match|
      field_name = $1
      placeholder = extract_placeholder(match)
      css_class = extract_css_class(match)
      "<input type=\"password\" name=\"#{field_name}\" class=\"#{css_class}\" placeholder=\"#{placeholder}\">"
    end

    # Convert labels
    content = content.gsub(/<%=\s*form\.label\s*:(\w+)(?:,\s*"([^"]*)")?[^%]*%>/) do |match|
      field_name = $1
      label_text = $2 || field_name.humanize
      css_class = extract_css_class(match)
      "<label class=\"#{css_class}\">#{label_text}</label>"
    end

    # Convert submit buttons
    content = content.gsub(/<%=\s*form\.submit\s*"([^"]*)"[^%]*%>/) do |match|
      button_text = $1
      css_class = extract_css_class(match)
      "<button type=\"submit\" class=\"#{css_class}\">#{button_text}</button>"
    end

    content
  end

  def extract_placeholder(erb_tag)
    match = erb_tag.match(/placeholder:\s*"([^"]*)"/)
    match ? match[1] : ""
  end

  def extract_css_class(erb_tag)
    match = erb_tag.match(/class:\s*"([^"]*)"/)
    match ? match[1] : ""
  end

  def render_component_navbar_items(component)
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

  def render_show_product_items(component)
    raw_template = component.template_patterns

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

    (1..5).map do |product|

        item_html = product_template.dup

        # Replace service template placeholders with actual service data
        item_html.gsub!('{{product_name}}', 'Product Name')
        item_html.gsub!('{{product_excerpt}}', 'Product Excerpt') # or service.description
        item_html.gsub!('{{product_image}}', 'https://placehold.co/600x400') # or whatever holds the image
        item_html.gsub!('{{product_image_alt}}', 'Product Name')
        item_html.gsub!('{{product_price}}', '199.99')
        item_html.gsub!('{{product_link}}', '#')
        item_html.gsub!('{{rating_count}}', '8')

        item_html
      end.join("\n")
  end
end
