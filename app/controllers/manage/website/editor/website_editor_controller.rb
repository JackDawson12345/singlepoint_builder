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

    if title == 'Sections'
      menu = component_types
      options = Component.all.group_by(&:component_type)

      possible_section_paths.each do |path|
        begin
          test_render = render_to_string(partial: path, locals: { menu: menu, options: options })

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
      menu = ['Colour Theme', 'Text Theme', 'Page Background', 'Page Transitions']
      content = 'Colours'
      possible_paths.each do |path|
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
    end



  end

  def sidebar_editor_fields_data
    component_id = params[:website_editor][:component_id]
    component_type = params[:website_editor][:component_type]
    theme_page_id = params[:website_editor][:theme_page_id]
    user_id = params[:website_editor][:user_id]

    possible_paths = [
      'editor_fields_sidebar',
      'manage/website/editor/website_editor/editor_fields_sidebar',
      'website_editor/editor_fields_sidebar'
    ]

    possible_paths.each do |path|
      begin
        test_render = render_to_string(partial: path, locals: { component_id: component_id, component_type: component_type, theme_page_id: theme_page_id, user_id: user_id })

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

    field_values = {}
    component.field_types.each do |name, type|
      field_values[name] = params[name] if params[name].present?
    end

    # Get current customisations
    website = user.website
    current_customisations = website.customisations&.dig("customisations") || []

    # Determine which theme_page_ids to update
    if component.global == true
      # For global components, get all theme_page_ids from the website
      theme_page_ids = website.pages["theme_pages"].values.map { |page_data| page_data["theme_page_id"] }

      # Remove old entries for this component across ALL theme_pages
      filtered_customisations = current_customisations.reject do |c|
        c["component_id"] == component.id.to_s
      end
    else
      # For non-global components, only update the current theme_page
      theme_page_ids = [theme_page_id]

      # Remove old entries for this component/theme_page combination only
      filtered_customisations = current_customisations.reject do |c|
        c["component_id"] == component.id.to_s && c["theme_page_id"] == theme_page_id.to_s
      end
    end

    # Create new customisation entries for each theme_page_id
    new_customisations = []
    theme_page_ids.each do |page_id|
      field_values.each do |field_name, field_value|
        new_customisations << {
          "component_id" => component.id.to_s,
          "theme_page_id" => page_id.to_s,
          "field_name" => field_name.to_s,
          "field_value" => field_value.to_s,
          "field_styling" => ""
        }
      end
    end

    # Add new customisations
    all_customisations = filtered_customisations + new_customisations

    # Update the website
    website.update!(customisations: { "customisations" => all_customisations })

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
