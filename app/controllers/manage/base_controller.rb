class Manage::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manage!
  before_action :has_website

  layout 'manage'


  def manage_help_search
    question = params[:search]

    if question.present?
      begin
        # Search for relevant articles
        relevant_articles = HelpArticle.search_by_keywords(question).limit(5)

        # Get all related articles (no limit)
        all_related_articles = HelpArticle.search_by_keywords(question)

        Rails.logger.info "Found #{relevant_articles.count} relevant articles for: #{question}"

        # Get AI response with context
        service = OpenaiHelpService.new
        @ai_response = service.answer_question(question, relevant_articles)

        Rails.logger.info "AI Response: #{@ai_response}"

        # Include article references with excerpts (25 words) and read time
        render json: {
          response: @ai_response,
          articles: all_related_articles.map { |a| {
            id: a.id,
            title: a.title,
            excerpt: a.excerpt(20),
            read_time: a.read_time,
            priority: a.priority
          }},
          article_count: all_related_articles.count
        }
      rescue StandardError => e
        Rails.logger.error "Error in manage_help_search: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")

        render json: {
          response: "Sorry, something went wrong. Please try again.",
          error: e.message,
          articles: [],
          article_count: 0
        }, status: 500
      end
    else
      render json: {
        response: "Please enter a question to get help.",
        articles: [],
        article_count: 0
      }
    end
  end

  def show_help_article
    @article = HelpArticle.find(params[:id])

    # Render a view or return JSON depending on your needs
    respond_to do |format|
      format.html # renders show_help_article.html.erb
      format.json { render json: @article }
    end
  end
  def search
    search_term = params[:search].to_s.strip

    if search_term.present?
      @results = ai_enhanced_search(search_term)
    else
      @results = []
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def ai_enhanced_search(query)
    all_pages = helpers.search_pages

    # If query is very short (1-2 chars), use simple matching
    if query.length < 3
      return all_pages.select { |p| p[:title].downcase.include?(query.downcase) }.take(5)
    end

    begin
      client = OpenAI::Client.new

      # Build a structured list of pages for the AI
      pages_list = all_pages.map.with_index do |page, idx|
        "#{idx + 1}. #{page[:title]}"
      end.join("\n")

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content: <<~PROMPT
              You are a search assistant for a website management dashboard.
              Your job is to match user queries to the most relevant pages.
              
              Rules:
              - Return ONLY a JSON array of numbers (the page numbers)
              - Order results by relevance (most relevant first)
              - Return up to 5 results
              - Consider synonyms and related terms
              - If the query is unclear, return the most likely matches
              
              Example response format: [3, 7, 1, 12]
            PROMPT
            },
            {
              role: "user",
              content: <<~QUERY
              User is searching for: "#{query}"
              
              Available pages:
              #{pages_list}
              
              Return the numbers of the most relevant pages as a JSON array.
            QUERY
            }
          ],
          temperature: 0.3,
          max_tokens: 100
        }
      )

      # Parse AI response
      ai_response = response.dig("choices", 0, "message", "content")
      page_indices = JSON.parse(ai_response)

      # Map indices back to pages
      results = page_indices.map do |idx|
        all_pages[idx - 1]
      end.compact

      # Fallback if no results
      results.any? ? results : fallback_search(query, all_pages)

    rescue JSON::ParserError => e
      Rails.logger.error "AI response parsing error: #{e.message}"
      fallback_search(query, all_pages)
    rescue => e
      Rails.logger.error "AI search error: #{e.message}"
      fallback_search(query, all_pages)
    end
  end

  def fallback_search(query, all_pages)
    # Simple keyword matching as fallback
    all_pages.select do |page|
      page[:title].downcase.include?(query.downcase)
    end.take(5)
  end

  def ensure_manage!
    if current_user.role == 1
      # Allowed
    elsif current_user.role == 0
      redirect_to admin_dashboard_path, alert: 'Access denied. Manage privileges required.'
    else
      redirect_to root_path, alert: 'Access denied. Manage privileges required.'
    end
  end

  def has_website
    unless current_user.website
      redirect_to manage_setup_path, alert: 'Please Set Up Your Website.'
    end
  end
end