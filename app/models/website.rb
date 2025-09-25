class Website < ApplicationRecord
  belongs_to :user
  belongs_to :theme
  has_many_attached :product_images
  # Add this line for image storage
  has_many_attached :editor_images
  has_one_attached :favicon
  validate :favicon_validation
  has_one :invoice_template, dependent: :destroy

  validates :user_id, uniqueness: { message: "can only have one website" }

  private

  def favicon_validation
    return unless favicon.attached?

    # Check content type
    allowed_types = ['image/png', 'image/jpeg', 'image/gif', 'image/x-icon', 'image/vnd.microsoft.icon']
    unless allowed_types.include?(favicon.blob.content_type)
      errors.add(:favicon, 'must be a PNG, JPEG, GIF, or ICO file')
    end

    # Check file size (1MB = 1,048,576 bytes)
    if favicon.blob.byte_size > 1.megabyte
      errors.add(:favicon, 'must be less than 1MB')
    end
  end
end
