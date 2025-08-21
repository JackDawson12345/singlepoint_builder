class Admin::ComponentsController < Admin::BaseController
  before_action :set_component, only: [:show, :edit, :update, :destroy]

  def index
    @components = Component.all.order(created_at: :desc)
  end

  def show
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
      Rails.logger.debug "Component saved successfully: #{@component.attributes.inspect}"
      redirect_to admin_components_show_path(@component), notice: 'Component was successfully created.'
    else
      Rails.logger.debug "Component save failed. Errors: #{@component.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    Rails.logger.debug "Updating component with params: #{component_params.inspect}"

    if @component.update(component_params)
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
end