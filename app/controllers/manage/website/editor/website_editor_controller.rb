class Manage::Website::Editor::WebsiteEditorController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manage!
  before_action :has_website
  before_action :start_editing
  layout 'editor'
  def index
    load_page_data("/")
    render :show
  end

  def inner_page
    load_inner_page_data(params[:page_slug], params[:inner_page_slug])
    render :show
  end

  def show
    load_page_data(params[:page_slug])

    if @page_data.nil?
      redirect_to manage_website_website_editor_path, alert: "Page not found"
      return
    end
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
      menu = ['Site Menu', 'Blog Pages', 'Service Pages', 'Shop Pages']
      options = current_user.website.theme.pages
      possible_pages_paths.each do |path|
        begin
          test_render = render_to_string(partial: path, locals: { menu: menu, options: options["theme_pages"] })

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

    field_values = {}
    field_stylings = {}

    # Define styling parameters that should be collected
    styling_params = %w[
    alignment text_colour font_family font_size font_weight
    font_transform font_style font_decoration line_height
    letter_spacing word_spacing
  ]

    # Collect styling information from params
    styling_data = {}
    styling_params.each do |style_param|
      param_value = params[style_param] || params.dig(:manage_website_editor_website_editor, style_param) || params.dig(:website_editor, style_param)
      if param_value.present?
        # Add 'px' suffix to size-related parameters if they're numeric
        if %w[font_size line_height letter_spacing word_spacing].include?(style_param) && param_value.match?(/^\d+$/)
          styling_data[style_param] = "#{param_value}px"
        else
          styling_data[style_param] = param_value
        end
      end
    end

    # Process each field based on its type, handling images with Active Storage
    component.field_types.each do |name, type|
      # Skip styling parameters as they're not field values
      next if styling_params.include?(name.to_s)

      # Try multiple parameter locations
      param_value = params[name] || params.dig(:manage_website_editor_website_editor, name) || params.dig(:website_editor, name)

      if type == 'image'
        remove_param = params["remove_#{name}"] || params.dig(:manage_website_editor_website_editor, "remove_#{name}")

        if remove_param == '1'
          field_values[name] = ''
          field_stylings[name] = styling_data
        elsif params[name].present? && params[name].respond_to?(:original_filename)
          # Handle image upload with Active Storage
          begin
            blob = ActiveStorage::Blob.create_and_upload!(
              io: params[name].open,
              filename: params[name].original_filename,
              content_type: params[name].content_type
            )

            # Store the blob URL as the field value
            field_values[name] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
            field_stylings[name] = styling_data
          rescue => e
            # Keep existing value if upload fails
            next
          end
        elsif params[name].blank?
          # If no new image and field is empty, keep existing value
          # This will be handled by not including it in field_values,
          # so existing customization will be preserved
          next
        end
      else
        # Handle text and textarea fields
        if param_value.present?
          field_values[name] = param_value
          field_stylings[name] = styling_data
        end
      end
    end

    # Get current customisations
    website = user.website
    current_customisations = website.customisations&.dig("customisations") || []

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

  private

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
