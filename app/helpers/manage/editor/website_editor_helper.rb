module Manage::Editor::WebsiteEditorHelper

  def render_editor_content(component)
    componentHTML = component.content['html']

    updated_content = componentHTML

    unless component.editable_fields == ""
      component.editable_fields.to_a.each do |field|
        updated_content = updated_content.gsub('{{'+field[0].to_s+'}}', field[1].to_s)
      end
    end

    updated_content


  end

end
