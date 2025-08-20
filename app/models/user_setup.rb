# Add these methods to your existing UserSetup model (app/models/user_setup.rb)

class UserSetup < ApplicationRecord
  belongs_to :user
  belongs_to :theme, optional: true # since theme might not be set initially

  def steps_completed
    steps = [
      !domain_name.nil?,
      !package_type.nil?,
      !support_option.nil?,
      !paid_at.nil?,
      !theme_id.nil?,
      built_website != 'Not Started',
      published == true
    ]

    steps.count(true)
  end

  def steps_percentage
    total_steps = 7
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
end