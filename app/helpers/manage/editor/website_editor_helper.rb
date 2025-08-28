module Manage::Editor::WebsiteEditorHelper

  def render_editor_content(component)
    componentHTML = component.content['html']

    updated_content = componentHTML

    unless component.editable_fields == ""
      component.editable_fields.to_a.each do |field|
        updated_content = updated_content.gsub('{{'+field[0].to_s+'}}', field[1].to_s)
      end
    end

    if updated_content.include?('{{nav_items}}')
      unless component.template_patterns == ""
        nav_items_html = render_navbar_items(component)
        updated_content = updated_content.gsub!('{{nav_items}}', nav_items_html)
      end
    end


    updated_content
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

      # Replace nav_item_link based on user role
      if pageSlug == '/'
        link = '/manage/website/editor/'
      else
        link = '/manage/website/editor/' + pageSlug
      end

      item_html.gsub!('{{nav_item_link}}', link)
      item_html
    end.join("\n")
  end

end
