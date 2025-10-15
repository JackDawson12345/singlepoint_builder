class Manage::Website::Editor::WebsiteEditorController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manage!
  before_action :has_website
  before_action :start_editing
  layout 'editor'
  def index
    load_page_data("/")

    @pages = current_user.website.theme.pages
    render :show
  end
  def inner_page
    load_inner_page_data(params[:page_slug], params[:inner_page_slug])
    @pages = current_user.website.theme.pages
    render :show
  end
  def show
    load_page_data(params[:page_slug])

    if @page_data.nil?
      redirect_to manage_website_website_editor_path, alert: "Page not found"
      return
    end

    @pages = current_user.website.theme.pages
  end
  def sidebar_data
    title = params[:title]

    # Try different partial paths
    possible_paths = [
      'editor_sidebar',
      'manage/website/editor/website_editor/editor_sidebar',
      'website_editor/editor_sidebar'
    ]

    possible_pages_paths = [
      'editor_pages_sidebar',
      'manage/website/editor/website_editor/editor_pages_sidebar',
      'website_editor/editor_pages_sidebar'
    ]

    possible_section_paths = [
      'editor_section_sidebar',
      'manage/website/editor/website_editor/editor_section_sidebar',
      'website_editor/editor_section_sidebar'
    ]

    possible_navigator_paths = [
      'editor_navigator_sidebar',
      'manage/website/editor/website_editor/editor_navigator_sidebar',
      'website_editor/editor_navigator_sidebar'
    ]

    possible_colour_paths = [
      'editor_colour_sidebar',
      'manage/website/editor/website_editor/editor_colour_sidebar',
      'website_editor/editor_colour_sidebar'
    ]


    if title == 'Sections'
      menu = component_types
      options = Component.all.group_by(&:component_type)
      theme_page_id = params[:theme_page_id]
      user_id = params[:user_id]
      area = params[:area]
      current_component_id = params[:current_component_id]

      possible_section_paths.each do |path|
        begin
          test_render = render_to_string(partial: path, locals: { menu: menu, options: options, theme_page_id: theme_page_id, user_id: user_id, area: area, current_component_id: current_component_id })

          respond_to do |format|
            format.json do
              render json: {
                html: test_render,
                success: true,
                path_used: path
              }
            end
          end

          return
        rescue => e
        end
      end
    elsif title == 'Site Pages and Menu'
      options = current_user.website.menu
      possible_pages_paths.each do |path|
        begin
          test_render = render_to_string(partial: path, locals: {options: options["menu_items"] })

          respond_to do |format|
            format.json do
              render json: {
                html: test_render,
                success: true,
                path_used: path
              }
            end
          end

          return
        rescue => e
        end
      end
    elsif title == 'Colours'
      menu = ['Colour Theme', 'Text Theme', 'Page Background']
      content = current_user.website.settings
      possible_colour_paths.each do |path|
        begin
          test_render = render_to_string(partial: path, locals: { menu: menu, options: content })

          respond_to do |format|
            format.json do
              render json: {
                html: test_render,
                success: true,
                path_used: path
              }
            end
          end

          return
        rescue => e
        end
      end
    elsif title == 'Navigator'

      websitePageID = params[:theme_page_id]
      website_pages = current_user.website.pages
      matching_page = website_pages["theme_pages"].find do |page_name, page_data|
        page_data["theme_page_id"] == websitePageID
      end

      components = matching_page[1]['components']

      possible_navigator_paths.each do |path|
        begin
          test_render = render_to_string(partial: path, locals: { components: components })

          respond_to do |format|
            format.json do
              render json: {
                html: test_render,
                success: true,
                path_used: path
              }
            end
          end

          return
        rescue => e
        end
      end
    end



  end
  def single_field_data
    field_name = params['field_name']
    theme_page_id = params['theme_page_id']
    component_id = params['component_id']

    possible_paths = [
      'editor_single_field_sidebar',
      'manage/website/editor/website_editor/editor_single_field_sidebar',
      'website_editor/editor_single_field_sidebar'
    ]

    possible_paths.each do |path|
      begin
        test_render = render_to_string(partial: path, locals: { field_name: field_name, theme_page_id: theme_page_id, component_id: component_id, user_id: current_user.id})

        respond_to do |format|
          format.json do
            render json: {
              html: test_render,
              success: true,
              path_used: path
            }
          end
        end

        return
      rescue => e
      end
    end

  end
  def page_type
    type = params[:type]
    title = params[:title]
    text = params[:text]

    @pageTemplates = PageTemplate.where(page_type: type)

    possible_paths = [
      'add_page_section',
      'layouts/add_page_section',
      'views/layouts/add_page_section'
    ]

    possible_paths.each do |path|
      begin
        test_render = render_to_string(
          partial: path,
          locals: {
            page_templates: @pageTemplates,
            type: type,
            title: title,
            text: text
          }
        )

        respond_to do |format|
          format.json do
            render json: {
              html: test_render,
              success: true,
              path_used: path
            }
          end
        end

        return
      rescue => e
        # Continue to next path if this one fails
      end
    end

    # If no partial was found, return an error
    respond_to do |format|
      format.json do
        render json: {
          success: false,
          error: 'Partial not found'
        }, status: :not_found
      end
    end
  end
  def sidebar_editor_fields_data
    component_id = params[:website_editor][:component_id]
    component_type = params[:website_editor][:component_type]
    theme_page_id = params[:website_editor][:theme_page_id]
    user_id = params[:website_editor][:user_id]
    component_page_id = params[:website_editor][:component_page_id]

    possible_paths = [
      'editor_fields_sidebar',
      'manage/website/editor/website_editor/editor_fields_sidebar',
      'website_editor/editor_fields_sidebar'
    ]

    possible_paths.each do |path|
      begin
        test_render = render_to_string(partial: path, locals: { component_id: component_id, component_type: component_type, theme_page_id: theme_page_id, user_id: user_id, component_page_id: component_page_id })

        respond_to do |format|
          format.json do
            render json: {
              html: test_render,
              success: true,
              path_used: path
            }
          end
        end

        return
      rescue => e
      end
    end

  end
  def sidebar_editor_fields_save
    component = Component.find(params[:component_id])
    theme_page_id = params[:theme_page_id]
    user = User.find(params[:user_id])
    component_page_id = params[:component_page_id]

    # Get the field name being edited directly from params
    active_field_name = params[:field_name] ||
                        params.dig(:manage_website_editor_website_editor, :field_name) ||
                        params.dig(:website_editor, :field_name)

    Rails.logger.debug "===== DEBUGGING ====="
    Rails.logger.debug "active_field_name: #{active_field_name.inspect}"
    Rails.logger.debug "All params keys: #{params.keys.inspect}"

    field_values = {}
    field_stylings = {}

    # Define styling parameters by field type
    text_styling_params = %w[
    alignment text_colour font_family font_size font_weight
    font_transform font_style font_decoration line_height
    letter_spacing word_spacing
  ]

    image_styling_params = %w[height object_fit]

    # Get current customisations BEFORE the loop
    website = user.website
    current_customisations = website.customisations&.dig("customisations") || []

    # Determine which fields to process
    # If active_field_name is provided, process only that field
    # Otherwise, process all background fields that are present in params
    fields_to_process = []

    if active_field_name
      fields_to_process = [active_field_name.to_s]
    else
      # Check for background fields in params
      component.field_types.each do |field_name, field_type|
        if field_name.to_s.include?('background')
          # Check if this field is in the params
          param_value = params[field_name] ||
                        params.dig(:manage_website_editor_website_editor, field_name) ||
                        params.dig(:website_editor, field_name)

          if param_value.present? || params["remove_#{field_name}"] == '1'
            fields_to_process << field_name.to_s
          end
        end
      end
    end

    Rails.logger.debug "fields_to_process: #{fields_to_process.inspect}"

    # Process each field
    fields_to_process.each do |field_name|
      field_data = component.field_types[field_name]

      Rails.logger.debug "Processing field: #{field_name}"
      Rails.logger.debug "field_data: #{field_data.inspect}"

      if field_data
        # Handle both simple types (e.g., "image", "color") and complex types (e.g., {"type" => "text", "style" => {...}})
        type = field_data.is_a?(Hash) ? field_data["type"] : field_data

        Rails.logger.debug "type: #{type}"

        param_value = params[field_name] ||
                      params.dig(:manage_website_editor_website_editor, field_name) ||
                      params.dig(:website_editor, field_name)

        Rails.logger.debug "param_value: #{param_value.inspect}"

        styling_data = {}

        # Collect styling for this field
        if type == 'text' || type == 'textarea'
          text_styling_params.each do |style_param|
            style_value = params[style_param] ||
                          params.dig(:manage_website_editor_website_editor, style_param) ||
                          params.dig(:website_editor, style_param)
            if style_value.present?
              if %w[font_size line_height letter_spacing word_spacing].include?(style_param) && style_value.match?(/^\d+$/)
                styling_data[style_param] = "#{style_value}px"
              else
                styling_data[style_param] = style_value
              end
            end
          end
        elsif type == 'image'
          image_styling_params.each do |style_param|
            style_value = params[style_param] ||
                          params.dig(:manage_website_editor_website_editor, style_param) ||
                          params.dig(:website_editor, style_param)
            if style_value.present?
              if style_param == 'height' && style_value.match?(/^\d+$/)
                styling_data[style_param] = "#{style_value}px"
              else
                styling_data[style_param] = style_value
              end
            end
          end
        end

        Rails.logger.debug "styling_data: #{styling_data.inspect}"

        # Process the field
        if type == 'image'
          remove_param = params["remove_#{field_name}"]

          Rails.logger.debug "remove_param: #{remove_param.inspect}"

          if remove_param == '1'
            field_values[field_name] = ''
            field_stylings[field_name] = styling_data
          elsif param_value.present?
            if param_value.is_a?(ActionDispatch::Http::UploadedFile) || param_value.respond_to?(:original_filename)
              begin
                blob = ActiveStorage::Blob.create_and_upload!(
                  io: param_value.tempfile || param_value.open,
                  filename: param_value.original_filename,
                  content_type: param_value.content_type
                )

                field_values[field_name] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
                field_stylings[field_name] = styling_data
                Rails.logger.debug "Uploaded image and saved to field_values: #{field_values[field_name]}"
              rescue => e
                Rails.logger.error "Failed to upload image: #{e.message}"
              end
            else
              field_values[field_name] = param_value
              field_stylings[field_name] = styling_data
            end
          elsif styling_data.present?
            Rails.logger.debug "Looking for existing customisation..."

            existing_customisation = current_customisations.find do |c|
              c["component_id"] == component.id.to_s &&
                c["theme_page_id"] == theme_page_id.to_s &&
                c["component_page_id"] == component_page_id &&
                c["field_name"] == field_name.to_s
            end

            Rails.logger.debug "existing_customisation: #{existing_customisation.inspect}"

            if existing_customisation && existing_customisation["field_value"].present?
              field_values[field_name] = existing_customisation["field_value"]
              field_stylings[field_name] = styling_data
              Rails.logger.debug "Set field_values from existing"
            else
              # No existing customisation - get the default value from component's editable_fields
              # Check if it's nested under 'background'
              default_value = component.editable_fields[field_name] ||
                              component.editable_fields.dig('background', field_name)

              if default_value.present?
                field_values[field_name] = default_value
                field_stylings[field_name] = styling_data
                Rails.logger.debug "Set field_values from default editable_fields: #{default_value}"
              else
                Rails.logger.debug "No existing customisation and no default value found"
              end
            end
          else
            Rails.logger.debug "No styling_data present"
          end
        elsif type == 'color'
          # Handle color fields
          if param_value.present?
            field_values[field_name] = param_value
            field_stylings[field_name] = styling_data
            Rails.logger.debug "Saved color value: #{param_value}"
          end
        else
          # Handle text and textarea fields
          if param_value.present?
            field_values[field_name] = param_value
            field_stylings[field_name] = styling_data
          elsif styling_data.present?
            existing_customisation = current_customisations.find do |c|
              c["component_id"] == component.id.to_s &&
                c["theme_page_id"] == theme_page_id.to_s &&
                c["component_page_id"] == component_page_id &&
                c["field_name"] == field_name.to_s
            end

            if existing_customisation && existing_customisation["field_value"].present?
              field_values[field_name] = existing_customisation["field_value"]
              field_stylings[field_name] = styling_data
            end
          end
        end
      else
        Rails.logger.debug "field_data was nil for field: #{field_name}"
      end
    end

    Rails.logger.debug "Final field_values: #{field_values.inspect}"
    Rails.logger.debug "===== END DEBUGGING ====="

    # Determine which theme_page_ids to update
    if component.global == true
      # For global components, get all theme_page_ids from the website
      theme_page_ids = website.pages["theme_pages"].values.flat_map do |page_data|
        ids = [page_data["theme_page_id"]]
        ids += page_data["inner_pages"].values.map { |inner_page| inner_page["theme_page_id"] }
        ids
      end

      # Remove old entries for this component across ALL theme_pages
      filtered_customisations = current_customisations.reject do |c|
        c["component_id"] == component.id.to_s
      end
    else
      # For non-global components, only update the current theme_page
      theme_page_ids = [theme_page_id]

      # Remove old entries for this component/theme_page combination only
      filtered_customisations = current_customisations.reject do |c|
        c["component_id"] == component.id.to_s && c["theme_page_id"] == theme_page_id.to_s && c["component_page_id"] == component_page_id
      end
    end

    if component.global == true
      new_customisations = []
      theme_page_ids.each do |page_id|
        page = website.pages["theme_pages"].values.find { |page| page["theme_page_id"] == page_id }

        if page
          # It's a main page
          component_data = page['components']&.find { |comp| comp['component_id'] == component.id }
        else
          # It might be an inner page - search through all main pages' inner_pages
          component_data = nil
          website.pages["theme_pages"].values.each do |main_page|
            inner_page = main_page["inner_pages"].values.find { |ip| ip["theme_page_id"] == page_id }
            if inner_page
              # Found the inner page, now get component data from parent's inner_pages_components
              component_data = main_page['inner_pages_components']&.find { |comp| comp['component_id'] == component.id }
              break if component_data
            end
          end
        end

        next unless component_data # Skip if component not found in page

        # For global components, we need to preserve existing values for fields not being updated
        if field_values.empty?
          # If no fields are being updated, preserve all existing customisations for this component
          existing_customisations_for_page = current_customisations.select do |c|
            c["component_id"] == component.id.to_s && c["theme_page_id"] == page_id.to_s
          end
          new_customisations.concat(existing_customisations_for_page)
        else
          # Get existing customisations for fields not being updated
          existing_for_page = current_customisations.select do |c|
            c["component_id"] == component.id.to_s &&
              c["theme_page_id"] == page_id.to_s &&
              c["component_page_id"] == component_data['component_page_id'] &&
              !field_values.key?(c["field_name"])
          end
          new_customisations.concat(existing_for_page)

          # Add new/updated field values with styling
          field_values.each do |field_name, field_value|
            new_customisations << {
              "component_id" => component.id.to_s,
              "component_page_id" => component_data['component_page_id'],
              "theme_page_id" => page_id.to_s,
              "field_name" => field_name.to_s,
              "field_value" => field_value.to_s,
              "field_styling" => field_stylings[field_name] || {}
            }
          end
        end
      end
    else
      # Create new customisation entries for each theme_page_id
      new_customisations = []

      # For non-global components, preserve existing values for fields not being updated
      if field_values.empty?
        # If no fields are being updated, preserve all existing customisations for this component
        existing_customisations_for_component = current_customisations.select do |c|
          c["component_id"] == component.id.to_s &&
            c["theme_page_id"] == theme_page_id.to_s &&
            c["component_page_id"] == component_page_id
        end
        new_customisations.concat(existing_customisations_for_component)
      else
        # Get existing customisations for fields not being updated
        existing_for_component = current_customisations.select do |c|
          c["component_id"] == component.id.to_s &&
            c["theme_page_id"] == theme_page_id.to_s &&
            c["component_page_id"] == component_page_id &&
            !field_values.key?(c["field_name"])
        end
        new_customisations.concat(existing_for_component)

        # Add new/updated field values with styling
        theme_page_ids.each do |page_id|
          field_values.each do |field_name, field_value|
            new_customisations << {
              "component_id" => component.id.to_s,
              "component_page_id" => component_page_id,
              "theme_page_id" => page_id.to_s,
              "field_name" => field_name.to_s,
              "field_value" => field_value.to_s,
              "field_styling" => field_stylings[field_name] || {}
            }
          end
        end
      end
    end

    # Add customisations that are NOT for this component (preserve other components' data)
    other_customisations = current_customisations.reject do |c|
      if component.global == true
        c["component_id"] == component.id.to_s
      else
        c["component_id"] == component.id.to_s && c["theme_page_id"] == theme_page_id.to_s && c["component_page_id"] == component_page_id
      end
    end

    # Combine all customisations
    all_customisations = other_customisations + new_customisations

    # Update the website
    website.update!(customisations: { "customisations" => all_customisations })

    respond_to do |format|
      format.html { redirect_back(fallback_location: manage_website_editor_website_editor_path, notice: 'Customisations saved!') }
      format.js # This will render sidebar_editor_fields_save.js.erb
    end

  rescue StandardError => e
    respond_to do |format|
      format.html { redirect_back(fallback_location: manage_website_editor_website_editor_path, alert: 'Error saving changes!') }
      format.js { render json: { error: 'An error occurred while saving' }, status: :internal_server_error }
    end
  end
  def add_section
    component = Component.find(params[:component_id])
    theme_page_id = params[:theme_page_id]
    user = User.find(params[:user_id])

    begin
      pages_data = user.website.pages
      updated = false

      pages_data["theme_pages"].each do |page_name, page_data|
        if page_data["theme_page_id"] == theme_page_id
          components = page_data["components"]

          if components.any?
            final_component_id = components.last['component_id']
            final_component = Component.find(final_component_id)

            if final_component.component_type == 'Footer'
              # Insert before the footer (which is the last component)
              next_position = components.map { |c| c["position"] }.max
              # Update footer position to make room
              components.last["position"] = next_position + 1
            else
              # Add after all existing components
              next_position = components.map { |c| c["position"] }.max + 1
            end
          else
            # No components exist, start with position 1
            next_position = 1
          end

          new_component = {"component_id" => component.id, component_page_id: SecureRandom.uuid, "position" => next_position}

          if components.any? && Component.find(components.last['component_id']).component_type == 'Footer'
            # Insert before the footer
            components.insert(-2, new_component)
          else
            # Add to the end
            components << new_component
          end

          updated = true
          break
        end
      end

      if updated
        user.website.update!(pages: pages_data)

        # Load the updated page data
        @website = user.website
        pages = @website.pages["theme_pages"]
        @page_data = pages.find do |key, page|
          page["theme_page_id"] == theme_page_id
        end&.last

        @page_data ||= {"components" => []}

        # Render the partial and return JSON
        rendered_html = render_to_string(partial: 'page_content', layout: false)

        render json: {
          success: true,
          message: "Component added successfully",
          html: rendered_html
        }
      else
        render json: {
          success: false,
          message: "Theme page not found"
        }
      end

    rescue => e
      render json: {
        success: false,
        message: "Error: #{e.message}"
      }
    end
  end
  def add_section_above
    component = Component.find(params[:component_id])
    theme_page_id = params[:theme_page_id]
    user = User.find(params[:user_id])
    current_component_id = params['current_component_id']

    page = user.website.pages["theme_pages"].values.find { |page| page["theme_page_id"] == theme_page_id }
    current_component_data = page['components'].find { |comp| comp['component_page_id'] == current_component_id }

    begin
      pages_data = user.website.pages
      updated = false

      pages_data["theme_pages"].each do |page_name, page_data|
        if page_data["theme_page_id"] == theme_page_id
          components = page_data["components"]
          insertion_position = current_component_data['position']

          # Update positions of all components at or after the insertion point
          components.each do |comp|
            if comp['position'] >= insertion_position
              comp['position'] += 1
            end
          end

          # Create new component with the insertion position
          new_component = {
            "component_id" => component.id,
            "component_page_id" => SecureRandom.uuid,
            "position" => insertion_position
          }

          # Insert the new component
          if components.any? && Component.find(components.last['component_id']).component_type == 'Footer'
            # Find the position to insert before footer
            footer_index = components.length - 1
            components.insert(footer_index, new_component)
          else
            # Add to components array (position is already set correctly)
            components << new_component
          end

          # Sort components by position to ensure correct order
          components.sort_by! { |comp| comp['position'] }

          updated = true
          break
        end
      end

      if updated
        user.website.update!(pages: pages_data)

        # Load the updated page data
        @website = user.website
        pages = @website.pages["theme_pages"]
        @page_data = pages.find do |key, page|
          page["theme_page_id"] == theme_page_id
        end&.last

        @page_data ||= {"components" => []}

        # Render the partial and return JSON
        rendered_html = render_to_string(partial: 'page_content', layout: false)

        render json: {
          success: true,
          message: "Component added successfully",
          html: rendered_html
        }
      else
        render json: {
          success: false,
          message: "Theme page not found"
        }
      end

    rescue => e
      render json: {
        success: false,
        message: "Error: #{e.message}"
      }
    end

  end
  def remove_section
    component = Component.find(params[:component_id])
    theme_page_id = params[:theme_page_id]
    user = User.find(params[:user_id])
    current_component_id = params['current_component_id']

    page = user.website.pages["theme_pages"].values.find { |page| page["theme_page_id"] == theme_page_id }
    current_component_data = page['components'].find { |comp| comp['component_page_id'] == current_component_id }

    begin
      pages_data = user.website.pages
      updated = false

      pages_data["theme_pages"].each do |page_name, page_data|
        if page_data["theme_page_id"] == theme_page_id
          components = page_data["components"]

          # Find the component to remove and get its position
          component_to_remove = components.find { |comp| comp['component_page_id'] == current_component_id }
          removal_position = component_to_remove['position']

          # Remove the component
          components.reject! { |comp| comp['component_page_id'] == current_component_id }

          # Update positions of all components after the removed component
          components.each do |comp|
            if comp['position'] > removal_position
              comp['position'] -= 1
            end
          end

          # Sort components by position to ensure correct order
          components.sort_by! { |comp| comp['position'] }

          updated = true
          break
        end
      end

      if updated
        user.website.update!(pages: pages_data)

        # Load the updated page data
        @website = user.website
        pages = @website.pages["theme_pages"]
        @page_data = pages.find do |key, page|
          page["theme_page_id"] == theme_page_id
        end&.last

        @page_data ||= {"components" => []}

        # Render the partial and return JSON
        rendered_html = render_to_string(partial: 'page_content', layout: false)

        render json: {
          success: true,
          message: "Component removed successfully",
          html: rendered_html
        }
      else
        render json: {
          success: false,
          message: "Theme page not found"
        }
      end

    rescue => e
      render json: {
        success: false,
        message: "Error: #{e.message}"
      }
    end
  end
  def reorder_components
    theme_page_id = params[:theme_page_id]
    user = User.find(params[:user_id])
    positions = params[:positions] # Array of {component_page_id, component_id, position}

    begin
      pages_data = user.website.pages
      updated = false

      pages_data["theme_pages"].each do |page_name, page_data|
        if page_data["theme_page_id"] == theme_page_id
          components = page_data["components"]

          # Update positions based on the new order
          positions.each do |pos_data|
            component = components.find { |c| c["component_page_id"] == pos_data["component_page_id"] }
            if component
              component["position"] = pos_data["position"]
            end
          end

          # Sort components by position to ensure correct order
          components.sort_by! { |comp| comp["position"] }

          updated = true
          break
        end
      end

      if updated
        user.website.update!(pages: pages_data)

        render json: {
          success: true,
          message: "Component positions updated successfully"
        }
      else
        render json: {
          success: false,
          message: "Theme page not found"
        }
      end

    rescue => e
      render json: {
        success: false,
        message: "Error: #{e.message}"
      }
    end
  end
  def update_colour_scheme
    current_settings = current_user.website.settings || {}

    # Extract params
    primary_colour = params[:primary_colour]
    secondary_colour = params[:secondary_colour]
    primary_hover_colour = params[:primary_hover_colour]
    secondary_hover_colour = params[:secondary_hover_colour]

    # Update the Colour Scheme section
    current_settings["Colour Scheme"] = {
      "primary_colour" => primary_colour,
      "secondary_colour" => secondary_colour,
      "primary_hover_colour" => primary_hover_colour,
      "secondary_hover_colour" => secondary_hover_colour
    }

    # Save back to website
    current_user.website.update(settings: current_settings)

    respond_to do |format|
      format.html { redirect_back(fallback_location: manage_website_editor_website_editor_path, notice: 'Customisations saved!') }
      format.js # This will render sidebar_editor_fields_save.js.erb
    end

  end
  def update_font_scheme
    current_settings = current_user.website.settings || {}

    # Extract params
    title_font = params[:title_font]
    text_font = params[:text_font]
    button_font = params[:button_font]

    # Update the Colour Scheme section
    current_settings["Font Scheme"] = {
      "title_font" => title_font,
      "text_font" => text_font,
      "button_font" => button_font
    }

    # Save back to website
    current_user.website.update(settings: current_settings)

    respond_to do |format|
      format.html { redirect_back(fallback_location: manage_website_editor_website_editor_path, notice: 'Customisations saved!') }
      format.js # This will render sidebar_editor_fields_save.js.erb
    end
  end
  def update_background_scheme

    current_settings = current_user.website.settings || {}

    # Extract params
    background_colour = params[:background_colour]

    # Update the Colour Scheme section
    current_settings["Background Colour Scheme"] = {
      "background_colour" => background_colour
    }

    # Save back to website
    current_user.website.update(settings: current_settings)

    respond_to do |format|
      format.html { redirect_back(fallback_location: manage_website_editor_website_editor_path, notice: 'Customisations saved!') }
      format.js # This will render sidebar_editor_fields_save.js.erb
    end
  end
  def update_positions
    pages = params[:pages]
    current_page_slug = params[:current_page_slug]
    current_menu = current_user.website.menu
    old_menu_items = current_menu["menu_items"]

    # Create a new menu structure
    new_menu_items = {}

    # First pass: Create all main pages
    main_page_position = 1
    pages.each do |page_data|
      next if page_data["isSubPage"] # Skip sub-pages in first pass

      page_name = page_data["name"]
      existing_page = find_existing_page(old_menu_items, page_name)

      unless existing_page
        Rails.logger.warn "Page not found: #{page_name}"
        next
      end

      new_menu_items[page_name] = {
        "id" => existing_page["id"],
        "slug" => existing_page["slug"],
        "position" => main_page_position.to_s,
        "inner_pages" => {}, # Start with empty inner_pages
        "show_in_menu" => existing_page["show_in_menu"]
      }
      main_page_position += 1
    end

    # Second pass: Add sub-pages to their parents
    pages.each do |page_data|
      next unless page_data["isSubPage"] # Only process sub-pages

      page_name = page_data["name"]
      parent_page_name = page_data["parentPage"]

      unless parent_page_name
        Rails.logger.warn "Sub-page #{page_name} has no parent, skipping"
        next
      end

      existing_page = find_existing_page(old_menu_items, page_name)
      unless existing_page
        Rails.logger.warn "Page not found: #{page_name}"
        next
      end

      # Make sure parent exists in new structure
      unless new_menu_items[parent_page_name]
        Rails.logger.warn "Parent page #{parent_page_name} not found for sub-page #{page_name}"
        next
      end

      # Calculate position within parent's inner_pages
      inner_position = (new_menu_items[parent_page_name]["inner_pages"].keys.length + 1).to_s

      # Add as inner page
      new_menu_items[parent_page_name]["inner_pages"][page_name] = {
        "id" => existing_page["id"],
        "slug" => existing_page["slug"],
        "position" => inner_position,
        "show_in_menu" => existing_page["show_in_menu"]
      }
    end

    # Update the menu
    current_menu["menu_items"] = new_menu_items

    if current_user.website.update(menu: current_menu)
      # Load the current page data before rendering
      load_page_data(current_page_slug)

      # Render the updated partial HTML
      updated_html = render_to_string(partial: "page_content", formats: [:html])

      render json: {
        success: true,
        message: "Pages reordered successfully",
        menu: new_menu_items,
        html: updated_html
      }
    else
      render json: {
        success: false,
        message: "Failed to update menu"
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error reordering pages: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    render json: {
      success: false,
      message: "Error: #{e.message}"
    }, status: :unprocessable_entity
  end
  def add_page_template
    page_template = PageTemplate.find(params['website_editor']['page_template_id'])
    user = current_user
    website = user.website
    pages = website.pages
    menu_data = website.menu

    # Find all existing "new page" variants in pages
    existing_keys = pages["theme_pages"].keys.select { |key| key.start_with?("new page") }

    # Determine the next number
    if existing_keys.empty?
      new_title = "new page"
      new_slug = "new-page"
    else
      numbers = existing_keys.map do |key|
        if key == "new page"
          0
        elsif match = key.match(/^new page (\d+)$/)
          match[1].to_i
        end
      end.compact

      next_number = (numbers.max || 0) + 1
      new_title = "new page #{next_number}"
      new_slug = "new-page-#{next_number}"
    end

    # Generate theme_page_id
    theme_page_id = SecureRandom.uuid

    # Transform components from page_template and generate component_page_ids
    components = page_template.components["components"].map do |comp|
      {
        "component_id" => comp["component_id"].to_i,
        "component_page_id" => SecureRandom.uuid,
        "position" => comp["position"]
      }
    end

    # Get the last position from existing pages
    last_page_position = pages["theme_pages"].values.map { |page| page["position"].to_i }.max || 0

    # Create the new page structure in theme_pages
    pages["theme_pages"][new_title] = {
      "theme_page_id" => theme_page_id,
      "components" => components,
      "inner_pages_components" => [],
      "inner_pages" => {},
      "slug" => new_slug,
      "package_type" => "Bespoke",
      "position" => (last_page_position + 1).to_s,
      "seo" => {
        "focus_keyword" => "",
        "title_tag" => "",
        "meta_description" => ""
      }
    }

    # Get the last position from menu
    last_menu_position = menu_data["menu_items"].values.map { |item| item["position"].to_i }.max || 0

    # Add the new menu item
    menu_data["menu_items"][new_title] = {
      "id" => SecureRandom.uuid,
      "slug" => new_slug,
      "position" => (last_menu_position + 1).to_s,
      "inner_pages" => {},
      'show_in_menu' => true
    }

    if website.save
      render json: { redirect_url: "/manage/website/editor/#{new_slug}" }
    else
      render json: { error: 'Failed to create page' }, status: :unprocessable_entity
    end
  end
  def show_in_menu
    menu_item_id = params[:menu_item_id]
    current_page_slug = params[:current_page_slug]
    menu_items = current_user.website.menu["menu_items"]
    menu_item_name, menu_item_data = menu_items.find { |key, value| value["id"] == menu_item_id }

    if menu_item_data
      menu_item_data["show_in_menu"] = !menu_item_data["show_in_menu"]

      if current_user.website.save
        # Load the current page data before rendering
        load_page_data(current_page_slug)

        # Render the updated partial HTML
        updated_html = render_to_string(partial: "page_content", formats: [:html])

        render json: {
          success: true,
          show_in_menu: menu_item_data["show_in_menu"],
          menu_item_id: menu_item_id,
          html: updated_html
        }
      else
        render json: { success: false, errors: current_user.website.errors }, status: :unprocessable_entity
      end
    else
      render json: { success: false, error: "Menu item not found" }, status: :not_found
    end
  end
  def delete_from_menu
    menu_item_id = params[:menu_item_id]
    current_page_slug = params[:current_page_slug]
    menu_items = current_user.website.menu["menu_items"]

    menu_item_name, menu_item_data = menu_items.find { |key, value| value["id"] == menu_item_id }

    if menu_item_name
      slug = menu_item_data["slug"]
      menu_items.delete(menu_item_name)
      current_user.website.pages["theme_pages"].delete(menu_item_name)

      if current_user.website.save
        # Check if we're deleting the current page
        if current_page_slug == slug
          # Don't try to render - just return success and let JS redirect
          render json: {
            success: true,
            message: "Menu item deleted",
            menu_item_id: menu_item_id,
            slug: slug,
            is_current_page: true
          }, status: :ok
        else
          # Load the current page data before rendering
          load_page_data(current_page_slug)

          # Render the updated partial HTML
          updated_html = render_to_string(partial: "page_content", formats: [:html])

          render json: {
            success: true,
            message: "Menu item deleted",
            menu_item_id: menu_item_id,
            slug: slug,
            html: updated_html,
            is_current_page: false
          }, status: :ok
        end
      else
        # Save failed
        render json: { success: false, errors: current_user.website.errors }, status: :unprocessable_entity
      end
    else
      # Menu item not found
      render json: { success: false, message: "Menu item not found" }, status: :not_found
    end
  end
  def duplicate_in_menu
    menu_item_id = params[:menu_item_id]
    menu_items = current_user.website.menu["menu_items"]
    theme_pages = current_user.website.pages["theme_pages"]

    menu_item_name, menu_item_data = menu_items.find { |key, value| value["id"] == menu_item_id }

    if !menu_item_name || !menu_item_data
      render json: { success: false, error: "Menu item not found" }, status: :not_found
      return
    end

    # Generate new name (projects -> projects 1, projects 1 -> projects 2, etc.)
    new_name = generate_unique_name(menu_items, menu_item_name)

    # === Duplicate Menu Item ===
    new_menu_item_data = menu_item_data.deep_dup
    new_menu_item_data["id"] = SecureRandom.uuid
    new_menu_item_data["slug"] = new_name.parameterize

    # Set position to be after all existing menu items
    max_menu_position = menu_items.values.map { |item| item["position"].to_i }.max
    new_menu_item_data["position"] = (max_menu_position + 1).to_s

    menu_items[new_name] = new_menu_item_data

    # === Duplicate Page ===
    original_page = theme_pages[menu_item_name]

    if original_page
      new_page_data = original_page.deep_dup

      # Generate new theme_page_id
      new_page_data["theme_page_id"] = SecureRandom.uuid

      # Update slug to match new menu item
      new_page_data["slug"] = new_name.parameterize

      # Set position to be after all existing pages
      max_page_position = theme_pages.values.map { |page| page["position"].to_i }.max
      new_page_data["position"] = (max_page_position + 1).to_s

      # Generate new component_page_id for each component
      new_page_data["components"].each do |component|
        component["component_page_id"] = SecureRandom.uuid
      end

      # Generate new component_page_id for each inner_pages_component
      new_page_data["inner_pages_components"].each do |component|
        component["component_page_id"] = SecureRandom.uuid
      end

      # Add duplicated page to theme_pages
      theme_pages[new_name] = new_page_data
    end

    # Save everything back to database
    website = current_user.website
    website.update(
      menu: website.menu,
      pages: website.pages
    )

    # Return success with new slug for redirect
    render json: {
      success: true,
      name: new_name,
      slug: new_menu_item_data["slug"]
    }
  end
  def rename_page
    menu_item_id = params[:menu_item_id]
    new_name = params[:new_name]
    current_page_slug = params[:current_page_slug]

    menu_items = current_user.website.menu["menu_items"]
    theme_pages = current_user.website.pages["theme_pages"]

    # Find the menu item (could be main page or inner page)
    result = find_menu_item_by_id(menu_items, menu_item_id)

    if !result
      render json: { success: false, message: "Menu item not found" }, status: :not_found
      return
    end

    menu_item_name = result[:name]
    menu_item_data = result[:data]
    parent_name = result[:parent]
    is_inner_page = result[:is_inner]

    # Store old slug to check if we're on the current page
    old_slug = menu_item_data["slug"]
    new_slug = new_name.parameterize

    # Check if new name already exists
    if is_inner_page
      # For inner pages, check within the parent's inner_pages
      parent_data = menu_items[parent_name]
      if parent_data["inner_pages"].key?(new_name) && new_name != menu_item_name
        render json: { success: false, message: "A page with this name already exists" }, status: :unprocessable_entity
        return
      end
    else
      # For main pages, check in menu_items
      if menu_items.key?(new_name) && new_name != menu_item_name
        render json: { success: false, message: "A page with this name already exists" }, status: :unprocessable_entity
        return
      end
    end

    # Update menu item and theme page
    if is_inner_page
      # Update inner page in menu
      parent_menu_data = menu_items[parent_name]
      parent_menu_data["inner_pages"][new_name] = parent_menu_data["inner_pages"].delete(menu_item_name)
      parent_menu_data["inner_pages"][new_name]["slug"] = new_slug

      # Update inner page in theme_pages
      parent_theme_data = theme_pages[parent_name]
      if parent_theme_data && parent_theme_data["inner_pages"]
        parent_theme_data["inner_pages"][new_name] = parent_theme_data["inner_pages"].delete(menu_item_name)
        parent_theme_data["inner_pages"][new_name]["slug"] = new_slug
      end
    else
      # Update main page in menu
      menu_items[new_name] = menu_items.delete(menu_item_name)
      menu_items[new_name]["slug"] = new_slug

      # Update main page in theme_pages
      if theme_pages[menu_item_name]
        theme_pages[new_name] = theme_pages.delete(menu_item_name)
        theme_pages[new_name]["slug"] = new_slug
      end
    end

    # Save changes
    if current_user.website.save
      # Check if we're renaming the current page
      is_current_page = (current_page_slug == old_slug || current_page_slug == "/#{old_slug}")

      if is_current_page
        render json: {
          success: true,
          message: "Page renamed successfully",
          new_slug: new_slug,
          is_current_page: true
        }
      else
        # For non-current pages, just return success without rendering HTML
        # The sidebar will be refreshed by the JavaScript
        render json: {
          success: true,
          message: "Page renamed successfully",
          new_slug: new_slug,
          is_current_page: false
        }
      end
    else
      render json: { success: false, message: "Failed to save changes" }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error renaming page: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { success: false, message: "Error: #{e.message}" }, status: :unprocessable_entity
  end

  private

  def generate_unique_name(menu_items, base_name)
    if base_name =~ /^(.+)\s+(\d+)$/
      prefix = $1
      number = $2.to_i
    else
      prefix = base_name
      number = 0
    end

    loop do
      number += 1
      new_name = "#{prefix} #{number}"
      return new_name unless menu_items.key?(new_name)
    end
  end

  def find_existing_page(menu_items, page_name)
    # Check main pages
    if menu_items[page_name]
      return menu_items[page_name]
    end

    # Check inner pages of all main pages
    menu_items.each do |parent_name, parent_data|
      if parent_data["inner_pages"] && parent_data["inner_pages"][page_name]
        return parent_data["inner_pages"][page_name]
      end
    end

    nil
  end

  def find_menu_item_by_id(menu_items, menu_item_id)
    # Check main pages
    menu_items.each do |page_name, page_data|
      if page_data["id"] == menu_item_id
        return {
          name: page_name,
          data: page_data,
          parent: nil,
          is_inner: false
        }
      end
    end

    # Check inner pages
    menu_items.each do |parent_name, parent_data|
      if parent_data["inner_pages"]
        parent_data["inner_pages"].each do |inner_page_name, inner_page_data|
          if inner_page_data["id"] == menu_item_id
            return {
              name: inner_page_name,
              data: inner_page_data,
              parent: parent_name,
              is_inner: true
            }
          end
        end
      end
    end

    nil
  end

  def load_page_data(slug)
    @website = current_user.website # Adjust this to however you're finding the website
    @page_slug = slug

    pages = @website.pages["theme_pages"]
    @page_data = pages.find do |key, page|
      page_slug = page["slug"]
      if slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == slug || page_slug == "/#{slug}"
      end
    end&.last

    pages = current_user.website.pages
    theme_page_id = @page_data['theme_page_id']

    @page_name = pages['theme_pages'].find { |name, data| data['theme_page_id'] == theme_page_id }&.first
  end
  def load_inner_page_data(slug, inner_slug)
    @website = current_user.website
    @page_slug = slug
    @inner_page_slug = inner_slug

    pages = @website.pages["theme_pages"]
    @all_page_data = pages.find do |key, page|
      page_slug = page["slug"]
      if slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == slug || page_slug == "/#{slug}"
      end
    end&.last

    # Capture both the key (page name) and the data
    @page_name, @page_data = @all_page_data['inner_pages'].find do |key, page|
      page_slug = page["slug"]
      if inner_slug == "/"
        page_slug == "/"
      else
        normalized_slug = page_slug.start_with?("/") ? page_slug[1..-1] : page_slug
        normalized_slug == inner_slug || page_slug == "/#{inner_slug}"
      end
    end

  end
  def ensure_manage!
    if current_user.role == 1

    elsif current_user.role == 0
      redirect_to admin_dashboard_path, alert: 'Access denied. Manage privileges required.'
    else
      redirect_to root_path, alert: 'Access denied. Manage privileges required.'
    end
  end
  def has_website
    unless current_user.website
      redirect_to manage_setup_path, alert: 'Please Set Up Your Website.'
    end
  end
  def start_editing
    if current_user.user_setup.built_website == 'Not Started'
      current_user.user_setup.update(built_website: 'Started')
    end
  end
end
