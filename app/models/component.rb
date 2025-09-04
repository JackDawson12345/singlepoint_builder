class Component < ApplicationRecord
  # Active Storage association for component image
  has_one_attached :component_image
  has_many_attached :images  # For storing all dynamic images

  # Validations
  validates :name, presence: true
  validates :component_type, presence: true
  validates :global, inclusion: { in: [true, false] }

  # Custom validation for component image
  validate :component_image_validation

  # Serialize the JSON fields (Rails 7+ with PostgreSQL handles this automatically, but good to be explicit)
  # attribute :content, :json
  # attribute :editable_fields, :json
  # attribute :field_types, :json
  # attribute :template_patterns, :json

  # Convenience methods for accessing content
  def html_content
    content&.dig('html')
  end

  def css_content
    content&.dig('css')
  end

  def js_content
    content&.dig('js')
  end

  # Convenience method for component image URL
  def component_image_url
    return nil unless component_image.attached?
    Rails.application.routes.url_helpers.rails_blob_path(component_image, only_path: true)
  end

  # Check if component has an image
  def has_component_image?
    component_image.attached?
  end

  def render_editor_content(component)
    byebug
  end

  def self.component_types
    [
      'Header',
      'Footer',
      'Breadcrumbs',
      'Tabs',
      'Hero Section',
      'Content Section',
      'Card',
      'Article/Blog Post',
      'Image Gallery',
      'Carousel/Slider',
      'Accordion',
      'Search Bar',
      'Progress Bar',
      'Rating/Stars',
      'Comments Section',
      'Social Share Buttons',
      'Testimonial',
      'Banner',
      'Call-to-Action',
      'Products',
      'Services',
      'Blogs',
      'Service Inner',
      'Blog Inner',
      'Product Inner'
    ]
  end

  private

  def component_image_validation
    return unless component_image.attached?

    # Check file size (10MB limit)
    if component_image.blob.byte_size > 10.megabytes
      errors.add(:component_image, 'must be less than 10MB')
    end

    # Check content type
    allowed_types = %w[image/jpeg image/jpg image/png image/gif image/webp]
    unless allowed_types.include?(component_image.blob.content_type)
      errors.add(:component_image, 'must be a valid image format (JPEG, PNG, GIF, WebP)')
    end
  end
end