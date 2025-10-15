class Admin::PageTemplatesController < Admin::BaseController
  before_action :set_page_template, only: [:show, :edit, :update, :destroy]
  include ActionView::Helpers::TextHelper

  def index
    @page_templates = PageTemplate.all.order(created_at: :desc)
  end

  def show
    @components = Component.all
  end

  def new
    @page_template = PageTemplate.new
  end

  def edit
  end

  def create
    @page_template = PageTemplate.new(page_template_params)

    if @page_template.save
      redirect_to admin_page_template_path(@page_template), notice: 'Page template was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @page_template.update(page_template_params)
      redirect_to admin_page_template_path(@page_template), notice: 'Page template was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page_template.destroy
    redirect_to admin_page_templates_url, notice: 'Page template was successfully deleted.'
  end

  def add_component
    @page_template = PageTemplate.find(params[:id])
    @page_template_components = @page_template.components['components']

    max_position = @page_template_components.map { |comp| comp[:position] || comp['position'] || 0 }.max || 0
    new_position = max_position + 1

    @page_template_components << {component_id: params[:component_id], position: new_position}
    @page_template.save

    respond_to do |format|
      format.html { redirect_to admin_page_template_path(id: @theme.id) }
      format.turbo_stream do
        # Only load components once and cache the count
        @components = Component.all
        components_count = @components.count
        page_components_count = @page_template_components.count

        # Use map and join instead of string concatenation
        if @page_template_components.any?
          sorted_components = @page_template_components.sort_by { |component| component[:position] || component['position'] || 0 }
          page_components_html = sorted_components.map do |page_template_component|
            render_to_string(
              partial: 'admin/page_templates/page_template_component',
              locals: {
                component_id: page_template_component[:component_id] || page_template_component['component_id'],
                position: page_template_component[:position] || page_template_component['position']
              },
              formats: [:html]
            )
          end.join
        else
          page_components_html = '
            <div id="empty-components-message" class="text-center py-8">
              <div class="w-12 h-12 mx-auto mb-4 text-gray-400">
                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012 2v2M7 7h10"></path>
                </svg>
              </div>
              <p class="text-gray-500 text-sm">No components added yet.</p>
              <p class="text-gray-400 text-xs mt-1">Add components from the left panel to get started</p>
            </div>'
        end

        # Use map and join for available components too
        available_components_html = @components.map do |component|
          render_to_string(
            partial: 'admin/page_templates/component',
            locals: { component: component },
            formats: [:html]
          )
        end.join

        render turbo_stream: [
          turbo_stream.update("page-components", "<div class=\"space-y-3\">#{page_components_html}</div>".html_safe),
          turbo_stream.update("available-components", "<div class=\"space-y-3\">#{available_components_html}</div>".html_safe),
          turbo_stream.update("component-stats",
                              "#{pluralize(components_count, 'component')} available • #{pluralize(page_components_count, 'component')} added")
        ]
      end
    end

  end

  def remove_component
    @page_template = PageTemplate.find(params[:id])
    @page_template_components = @page_template.components['components']
    component_id_to_remove = params[:component_id].to_s

    # Remove the component from the components array
    @page_template_components.reject! do |comp|
      (comp['component_id'] || comp[:component_id]).to_s == component_id_to_remove
    end

    @page_template.save

    # Reload components for fresh data
    @components = Component.all

    respond_to do |format|
      format.html { redirect_to admin_page_template_path(id: @page_template.id) }
      format.turbo_stream do

        components_count = @components.count
        page_components_count = @page_template.components['components'].count

        # Build the page components HTML
        page_components_html = '<div class="space-y-3">'

        if @page_template.components['components'].any?
          @page_template.components['components'].sort_by { |component| component[:position] || component['position'] || 0 }.each do |page_template_component|
            page_components_html += render_to_string(
              partial: 'admin/page_templates/page_template_component',
              locals: {
                component_id: page_template_component[:component_id] || page_template_component['component_id'],
                position: page_template_component[:position] || page_template_component['position']
              },
              formats: [:html]
            )
          end
        else
          page_components_html += '
          <div id="empty-components-message" class="text-center py-8">
            <div class="w-12 h-12 mx-auto mb-4 text-gray-400">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012 2v2M7 7h10"></path>
              </svg>
            </div>
            <p class="text-gray-500 text-sm">No components added yet.</p>
            <p class="text-gray-400 text-xs mt-1">Add components from the left panel to get started</p>
          </div>'
        end

        page_components_html += '</div>'

        # Build the available components HTML
        available_components_html = '<div class="space-y-3">'
        @components.each do |component|
          available_components_html += render_to_string(
            partial: 'admin/page_templates/component',
            locals: { component: component },
            formats: [:html]
          )
        end
        available_components_html += '</div>'

        render turbo_stream: [
          turbo_stream.update("page-components", page_components_html.html_safe),
          turbo_stream.update("available-components", available_components_html.html_safe),
          turbo_stream.update("component-stats",
                              "#{components_count} #{'component'.pluralize(components_count)} available • #{page_components_count} #{'component'.pluralize(page_components_count)} added")
        ]
      end
    end
  end

  def reorder_components
    @page_template = PageTemplate.find(params[:id])
    positions = params[:positions]

    return head :bad_request if positions.blank?

    # Get current components
    components = @page_template.components['components']

    # Update positions
    positions.each do |pos_data|
      component_id = pos_data[:component_id].to_s
      new_position = pos_data[:position].to_i

      # Find and update the component
      component = components.find do |comp|
        (comp['component_id'] || comp[:component_id]).to_s == component_id
      end

      if component
        component['position'] = new_position
        component[:position] = new_position
      end
    end

    # Save the updated components
    @page_template.save

    respond_to do |format|
      format.json { head :ok }
    end
  end

  private

  def set_page_template
    @page_template = PageTemplate.find(params[:id])
  end

  def page_template_params
    params.require(:page_template).permit(:title, :page_type, :screenshot)
  end
end
