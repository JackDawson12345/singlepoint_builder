# app/controllers/admin/help_articles_controller.rb
class Admin::HelpArticlesController < Admin::BaseController
  before_action :set_help_article, only: [:show, :edit, :update, :destroy]

  def index
    @help_articles = HelpArticle.all.order(priority: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @help_article = HelpArticle.new
  end

  def create
    @help_article = HelpArticle.new(help_article_params)
    @help_article.user = current_user

    # Convert comma-separated keywords to array
    if params[:help_article][:keywords_input].present?
      @help_article.keywords = params[:help_article][:keywords_input].split(',').map(&:strip).reject(&:blank?)
    end

    if @help_article.save
      redirect_to [:admin, @help_article], notice: 'Help article was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @help_article.update(help_article_params)
      redirect_to [:admin, @help_article], notice: 'Help article was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @help_article.destroy
    redirect_to admin_help_articles_url, notice: 'Help article was successfully deleted.'
  end

  private

  def set_help_article
    @help_article = HelpArticle.find(params[:id])
  end

  def help_article_params
    params.require(:help_article).permit(:title, :text, :priority, images: [])
  end
end