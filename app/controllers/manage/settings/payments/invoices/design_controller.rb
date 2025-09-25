class Manage::Settings::Payments::Invoices::DesignController < ApplicationController

  layout 'invoice_design'
  def index

  end

  def load_partial

    partial_name = params[:partial]
    allowed_partials = %w[text dividers image]

    if allowed_partials.include?(partial_name)
      render partial: partial_name, layout: false
    else
      head :not_found
    end
  end

  def load_text_partial

    partial_name = 'text_customise'
    text_name = params[:partial]
    allowed_partials = %w[text_customise]

    if allowed_partials.include?(partial_name)
      render partial: partial_name, layout: false, locals: { text_name: text_name}
    else
      head :not_found
    end
  end

  def update_design

    design_params = params.require(:invoice_template).permit(
      :current_text_element,
      design: {
        text: {
          headline: [:font, :size, :color, style: [:bold, :underline, :italic]],
          title: [:font, :size, :color, style: [:bold, :underline, :italic]],
          text: [:font, :size, :color, style: [:bold, :underline, :italic]],
          items: [:font, :size, :color, style: [:bold, :underline, :italic]]
        }
      }
    )

    if current_user.website.invoice_template.update(design: design_params[:design])
      respond_to do |format|
        format.html { redirect_back(fallback_location: manage_settings_payments_invoices_design_invoices_path) }
        format.json { render json: { status: 'success', message: 'Design updated successfully' } }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: manage_settings_payments_invoices_design_invoices_path, alert: 'Failed to update design') }
        format.json { render json: { status: 'error', message: 'Failed to update design' }, status: 422 }
      end
    end
  end

end
