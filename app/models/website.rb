class Website < ApplicationRecord
  belongs_to :user
  belongs_to :theme

  validates :user_id, uniqueness: { message: "can only have one website" }
end
