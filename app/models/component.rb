class Component < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :component_type, presence: true
  validates :global, inclusion: { in: [true, false] }

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

  def render_editor_content(component)
    byebug
  end
end
