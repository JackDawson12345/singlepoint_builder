class OpenaiHelpService
  def initialize
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.dig(:openai, :api_key)
    )
  end

  def answer_question(question, relevant_articles)
    # Extract relevant content including step-by-step instructions
    context = extract_relevant_content(question, relevant_articles)

    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          {
            role: "system",
            content: "You are a helpful assistant for a website builder platform called Singlepoint. When answering questions, provide clear step-by-step instructions from the help articles. Always include numbered steps, bullet points, and detailed procedural information when available. Format your response to be actionable and easy to follow."
          },
          {
            role: "user",
            content: "Help Article Content:\n#{context}\n\nQuestion: #{question}\n\nProvide a clear answer with step-by-step instructions if available in the articles."
          }
        ],
        temperature: 0.7,
        max_tokens: 800
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue StandardError => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    "Sorry, I couldn't process your question at the moment. Please try again later."
  end

  private

  def extract_relevant_content(question, articles)
    return "No relevant information found." if articles.empty?

    search_terms = question.downcase.split(/\s+/).reject { |t| t.length < 3 }

    articles.map do |article|
      # Extract procedural content (numbered lists, bullet points, step-by-step)
      relevant_content = extract_procedural_content(article.text, search_terms)

      "Article: #{article.title}\n\n#{relevant_content}\n---"
    end.join("\n\n")
  end

  def extract_procedural_content(text, search_terms)
    paragraphs = text.split(/\n\n+/).map(&:strip).reject(&:blank?)

    # Score paragraphs by relevance and type
    scored_paragraphs = paragraphs.map do |paragraph|
      score = calculate_content_score(paragraph, search_terms)
      { text: paragraph, score: score }
    end

    # Get paragraphs with score > 0, prioritizing instructional content
    relevant_paragraphs = scored_paragraphs
                            .select { |p| p[:score] > 0 }
                            .sort_by { |p| -p[:score] }
                            .take(8) # Increased from 2 to get more context including steps
                            .map { |p| p[:text] }

    if relevant_paragraphs.any?
      relevant_paragraphs.join("\n\n")
    else
      # Fallback: get first few paragraphs
      paragraphs.take(3).join("\n\n")
    end
  end

  def calculate_content_score(text, search_terms)
    text_lower = text.downcase
    score = 0

    # Score for search terms
    search_terms.each do |term|
      occurrences = text_lower.scan(term).length
      score += occurrences * 3

      # Bonus for terms near the start
      score += 5 if text_lower[0..150].include?(term)
    end

    # Bonus for instructional content patterns
    score += 15 if text =~ /^\d+\./m # Numbered lists
    score += 10 if text.include?('*') && text.include?(':') # Bullet points with descriptions
    score += 8 if text_lower.include?('step')
    score += 8 if text_lower =~ /\b(click|navigate|go to|open|select|choose)\b/
    score += 5 if text_lower.include?('how to')
    score += 5 if text_lower.include?('you will') || text_lower.include?('you can')

    # Prioritize paragraphs with multiple lines (likely instructions)
    score += 5 if text.count("\n") > 2

    score
  end
end