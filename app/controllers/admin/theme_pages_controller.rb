class Admin::ThemePagesController < Admin::BaseController
  def index
    @theme = Theme.find(params[:id])
    @pageName, @themePage = @theme.pages["theme_pages"].find do |name, page|
      page["theme_page_id"] == params[:theme_page_id]
    end
    @all_components = Component.all
    @components = Component.all
  end

  def add_component
    @theme = Theme.find(params[:id])
    @pageName, @themePage = @theme.pages["theme_pages"].find do |name, page|
      page["theme_page_id"] == params[:theme_page_id]
    end

    # Get the maximum position from existing components and add 1
    max_position = @themePage['components'].map { |comp| comp[:position] || comp['position'] || 0 }.max || 0
    new_position = max_position + 1

    @themePage['components'] << {component_id: params[:component_id].to_i, position: new_position}
    @theme.save

    respond_to do |format|
      format.html { redirect_to admin_theme_pages_show_path(id: @theme.id, theme_page_id: params[:theme_page_id]) }
      format.turbo_stream do
        # Only load components once and cache the count
        @components = Component.all
        components_count = @components.count
        page_components_count = @themePage['components'].count

        # Use map and join instead of string concatenation
        if @themePage['components'].any?
          sorted_components = @themePage['components'].sort_by { |component| component[:position] || component['position'] || 0 }
          page_components_html = sorted_components.map do |theme_page_component|
            render_to_string(
              partial: 'admin/theme_pages/theme_page_component',
              locals: { theme_page_component: theme_page_component },
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
            partial: 'admin/theme_pages/component',
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
    @theme = Theme.find(params[:id])
    @pageName, @themePage = @theme.pages["theme_pages"].find do |name, page|
      page["theme_page_id"] == params[:theme_page_id]
    end
    component_id_to_remove = params[:component_id].to_s

    # Remove the component from the components array
    @themePage['components'].reject! do |comp|
      (comp['component_id'] || comp[:component_id]).to_s == component_id_to_remove
    end

    @theme.save

    # Reload components for fresh data
    @components = Component.all

    respond_to do |format|
      format.html { redirect_to admin_theme_pages_show_path(id: @theme.id, theme_page_id: params[:theme_page_id]) }
      format.turbo_stream do

        components_count = @components.count
        page_components_count = @themePage['components'].count

        # Build the page components HTML
        page_components_html = '<div class="space-y-3">'

        if @themePage['components'].any?
          @themePage['components'].sort_by { |component| component[:position] || component['position'] || 0 }.each do |theme_page_component|
            page_components_html += render_to_string(
              partial: 'admin/theme_pages/theme_page_component',
              locals: { theme_page_component: theme_page_component },
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
            partial: 'admin/theme_pages/component',
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
    @theme = Theme.find(params[:id])
    @pageName, @themePage = @theme.pages["theme_pages"].find do |name, page|
      page["theme_page_id"] == params[:theme_page_id]
    end

    positions = JSON.parse(request.body.read)['positions']

    # Update positions for each component
    positions.each do |pos_data|
      component_id = pos_data['component_id'].to_s
      new_position = pos_data['position'].to_i

      # Find and update the component position
      @themePage['components'].each do |comp|
        if (comp['component_id'] || comp[:component_id]).to_s == component_id
          # Only update one key, remove the duplicate assignment
          if comp.key?('component_id')
            comp['position'] = new_position
          else
            comp[:position] = new_position
          end
        end
      end
    end

    @theme.save

    respond_to do |format|
      format.html { redirect_to admin_theme_pages_show_path(id: @theme.id, theme_page_id: params[:theme_page_id]) }
      format.turbo_stream { head :ok }
      format.json { head :ok }
    end
  end
end
