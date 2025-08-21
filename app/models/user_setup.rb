class UserSetup < ApplicationRecord
  belongs_to :user
  belongs_to :theme, optional: true # since theme might not be set initially

  def steps_completed
    steps = [
      !domain_name.nil?,
      !package_type.nil?,
      !support_option.nil?,
      !paid_at.nil?,
      domain_purchased?, # Updated to check if domain was purchased
      !theme_id.nil?,
      built_website != 'Not Started',
      published == true
    ]

    steps.count(true)
  end

  def steps_percentage
    total_steps = 8 # Updated to 8 steps including domain purchase
    return 0 if total_steps.zero?

    (steps_completed.to_f / total_steps * 100).round
  end

  # New pricing methods
  def base_price
    case package_type&.downcase
    when 'bespoke'
      500.00
    when 'e-commerce'
      1000.00
    else
      200.00 # Default fallback price
    end
  end

  def requires_full_payment?
    support_option == 'Do It Myself'
  end

  def payment_amount
    if requires_full_payment?
      base_price
    else
      (base_price * 0.20).round(2) # 20% deposit
    end
  end

  def payment_amount_pence
    (payment_amount * 100).to_i
  end

  def is_deposit_payment?
    !requires_full_payment?
  end

  def remaining_amount
    return 0.00 if requires_full_payment?
    (base_price - payment_amount).round(2)
  end

  def payment_type_description
    if requires_full_payment?
      'Full Payment'
    else
      '20% Deposit'
    end
  end

  def payment_summary
    {
      base_price: base_price,
      payment_amount: payment_amount,
      payment_amount_pence: payment_amount_pence,
      is_deposit: is_deposit_payment?,
      remaining_amount: remaining_amount,
      payment_type: payment_type_description
    }
  end

  # New domain purchase methods
  def domain_purchased?
    domain_purchased == true
  end

  def domain_purchase_successful?
    domain_purchased? && domain_purchase_error.blank?
  end

  def domain_purchase_failed?
    !domain_purchased? && domain_purchase_error.present?
  end

  def domain_registration_date
    return nil unless domain_purchase_details.present?

    if domain_purchase_details['registered_at']
      Time.parse(domain_purchase_details['registered_at'])
    end
  rescue
    nil
  end

  def domain_expires_at
    reg_date = domain_registration_date
    return nil unless reg_date

    years = domain_purchase_details&.dig('years') || 1
    reg_date + years.years
  end

  def domain_purchase_summary
    {
      purchased: domain_purchased?,
      successful: domain_purchase_successful?,
      failed: domain_purchase_failed?,
      error: domain_purchase_error,
      registered_at: domain_registration_date,
      expires_at: domain_expires_at,
      details: domain_purchase_details
    }
  end
end