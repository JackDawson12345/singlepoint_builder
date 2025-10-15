class HelpArticle < ApplicationRecord

  belongs_to :user

  scope :search_by_keywords, ->(query) {
    return none if query.blank?

    search_terms = query.downcase.split(/\s+/).select { |term| term.length >= 3 }
    return none if search_terms.empty?

    # More strict: require ALL search terms to match
    results = all

    search_terms.each do |term|
      sanitized_term = "%#{term}%"
      results = results.where(
        "LOWER(title) LIKE ? OR LOWER(text) LIKE ? OR LOWER(keywords::text) LIKE ?",
        sanitized_term, sanitized_term, sanitized_term
      )
    end

    results.order(priority: :desc)
  }

  # Get first 25 words of text
  def excerpt(word_count = 20)
    return '' if text.blank?
    words = text.split(/\s+/)
    excerpt_text = words.first(word_count).join(' ')
    excerpt_text += '...' if words.length > word_count
    excerpt_text
  end

  # Calculate read time (assuming 200 words per minute)
  def read_time
    return 1 if text.blank?
    word_count = text.split(/\s+/).length
    minutes = (word_count / 200.0).ceil
    minutes < 1 ? 1 : minutes
  end
end