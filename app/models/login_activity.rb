class LoginActivity < ApplicationRecord
  belongs_to :user

  scope :recent, -> { order(login_at: :desc) }
  scope :last_30_days, -> { where(login_at: 30.days.ago..Time.current) }

  def location_display
    [city, country].compact.join(', ')
  end

  def browser_display
    return 'Unknown Browser' if browser.blank?

    # Just return the first word (browser name)
    browser.split(' ').first
  end
end
