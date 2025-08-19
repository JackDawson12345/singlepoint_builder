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
end
