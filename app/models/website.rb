class Website < ApplicationRecord
  belongs_to :user
  belongs_to :theme
  has_many_attached :product_images

  validates :user_id, uniqueness: { message: "can only have one website" }
end
