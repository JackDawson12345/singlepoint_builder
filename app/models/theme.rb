# app/models/theme.rb
class Theme < ApplicationRecord
  has_one_attached :image

  validates :name, presence: true
  validates :description, presence: true
  validates :pages, presence: true

  # Custom validation for image
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 10.megabytes
      errors.add(:image, "is too big (should be less than 10MB)")
    end

    # Added WebP to acceptable types
    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"]
    unless acceptable_types.include?(image.blob.content_type)
      errors.add(:image, "must be a JPEG, PNG, GIF, or WebP")
    end
  end
end