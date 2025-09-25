class Manage::Settings::Payments::InvoicesController < Manage::BaseController

  def index

    @invoice_template = current_user.website.invoice_template

  end

  def numbering_save
    user = current_user
    website = user.website
    invoice_template = website.invoice_template
    numbering = invoice_template.numbering

    # Update the numbering hash with new values
    numbering['invoice_numbering'] = params['invoice_number'] if params['invoice_number'].present?
    numbering['prefix'] = params['prefix'] if params['prefix'].present?
    numbering['suffix'] = params['suffix'] if params['suffix'].present?

    # Save the updated numbering back to the invoice template
    if invoice_template.update(numbering: numbering)
      respond_to do |format|
        format.turbo_stream { render :numbering_save } # Add this line
        format.js { render :numbering_save }
        format.html { redirect_back(fallback_location: manage_settings_payments_invoices_path, notice: 'Changes saved successfully') }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :numbering_error } # Add this line
        format.js { render :numbering_error }
        format.html { redirect_back(fallback_location: manage_settings_payments_invoices_path, alert: 'Failed to save changes') }
      end
    end
  end

  def header_fields_save
    user = current_user
    website = user.website
    invoice_template = website.invoice_template
    header_fields = invoice_template.header_fields || {}

    # Collect all custom field values and compact them (remove empty ones)
    custom_field_values = [
      params['custom_field_one'],
      params['custom_field_two'],
      params['custom_field_three'],
      params['custom_field_four']
    ].compact.reject(&:blank?)

    # Pad with empty strings to maintain 4 slots
    while custom_field_values.length < 4
      custom_field_values << ''
    end

    # Update the nested structure with compacted values
    header_fields['invoice_title'] = params['invoice_title'] || ''
    header_fields['custom_fields'] = {
      'custom_field_one' => custom_field_values[0] || '',
      'custom_field_two' => custom_field_values[1] || '',
      'custom_field_three' => custom_field_values[2] || '',
      'custom_field_four' => custom_field_values[3] || ''
    }

    if invoice_template.update(header_fields: header_fields)
      respond_to do |format|
        format.turbo_stream { render :header_fields_save }
        format.js { render :header_fields_save }
        format.html { redirect_back(fallback_location: manage_settings_payments_invoices_path, notice: 'Changes saved successfully') }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :header_fields_error }
        format.js { render :header_fields_error }
        format.html { redirect_back(fallback_location: manage_settings_payments_invoices_path, alert: 'Failed to save changes') }
      end
    end
  end
end
