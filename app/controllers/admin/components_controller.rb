class Admin::ComponentsController < Admin::BaseController
  before_action :set_component, only: [:show, :edit, :update, :destroy]

  def index
    @components = Component.all.order(created_at: :desc)
  end

  def show
  end

  def preview
    @component = Component.find(params[:id])
    render layout: false
  end

  def new
    @component = Component.new
  end

  def edit
  end

  def create
    @component = Component.new(component_params)

    Rails.logger.debug "Component attributes before save: #{@component.attributes.inspect}"

    if @component.save
      # Process dynamic image uploads and update editable_fields
      process_dynamic_image_uploads

      Rails.logger.debug "Component saved successfully: #{@component.attributes.inspect}"
      redirect_to admin_components_show_path(@component), notice: 'Component was successfully created.'
    else
      Rails.logger.debug "Component save failed. Errors: #{@component.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end


  def update
    Rails.logger.debug "Updating component with params: #{component_params.inspect}"

    # Handle image removal if requested
    if params[:component][:remove_component_image] == '1'
      @component.component_image.purge if @component.component_image.attached?
    end

    if @component.update(component_params.except(:remove_component_image))
      # Process dynamic image uploads and update editable_fields
      process_dynamic_image_uploads

      Rails.logger.debug "Component updated successfully: #{@component.attributes.inspect}"
      redirect_to admin_components_show_path(@component), notice: 'Component was successfully updated.'
    else
      Rails.logger.debug "Component update failed. Errors: #{@component.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @component.destroy
    redirect_to admin_components_path, notice: 'Component was successfully deleted.'
  end

  private

  def set_component
    @component = Component.find(params[:id])
  end

  def component_params
    permitted_params = params.require(:component).permit(
      :name,
      :component_type,
      :global,
      :editable_fields,
      :field_types,
      :template_patterns,
      :component_image,
      :remove_component_image,
      content: [:html, :css, :js]
    )

    # Debug: Log the incoming params
    Rails.logger.debug "Raw params: #{params[:component].inspect}"
    Rails.logger.debug "Permitted params before processing: #{permitted_params.inspect}"

    # Handle JSON field parsing for form submission
    %w[editable_fields field_types template_patterns].each do |field|
      if permitted_params[field].present? && permitted_params[field].is_a?(String)
        begin
          permitted_params[field] = JSON.parse(permitted_params[field])
        rescue JSON::ParserError => e
          @component&.errors&.add(field.to_sym, "must be valid JSON: #{e.message}")
        end
      end
    end

    Rails.logger.debug "Final permitted params: #{permitted_params.inspect}"
    permitted_params
  end

  def process_dynamic_image_uploads
    return unless @component.field_types.is_a?(Hash)

    # Find all image fields from field_types
    image_fields = @component.field_types.select { |key, value| value == 'image' }.keys

    # Get current editable_fields
    editable_fields = @component.editable_fields.is_a?(Hash) ? @component.editable_fields.dup : {}

    image_fields.each do |field_name|
      image_param_name = "#{field_name}_image"

      if params[:component] && params[:component][image_param_name].present?
        # Remove any existing image for this field
        existing_attachment = @component.images.attachments.find { |att| att.metadata['field_name'] == field_name }
        existing_attachment&.purge

        # Attach new image with metadata
        @component.images.attach(
          io: params[:component][image_param_name],
          filename: "#{field_name}_#{params[:component][image_param_name].original_filename}",
          metadata: { field_name: field_name }
        )

        # Find the just-attached image and get its URL
        attached_image = @component.images.attachments.find { |att| att.metadata['field_name'] == field_name }
        if attached_image
          editable_fields[field_name] = Rails.application.routes.url_helpers.rails_blob_url(attached_image, only_path: true)
        end
      end
    end

    # Update the component with new editable_fields if they changed
    if editable_fields != @component.editable_fields
      @component.update_column(:editable_fields, editable_fields)
    end
  end
end