class Website < ApplicationRecord
  belongs_to :user
  belongs_to :theme
  has_many_attached :product_images
  # Add this line for image storage
  has_many_attached :editor_images

  validates :user_id, uniqueness: { message: "can only have one website" }
end
