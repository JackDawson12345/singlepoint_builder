class UserConnection < ApplicationRecord
  belongs_to :user

  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
  validates :provider, inclusion: { in: %w[google_oauth2 facebook] }

  scope :by_provider, ->(provider) { where(provider: provider) }
end
