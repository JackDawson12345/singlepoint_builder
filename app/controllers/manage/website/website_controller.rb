class Manage::Website::WebsiteController <  Manage::BaseController

  skip_before_action :has_website

  def index
    @themes = Theme.all
  end

  def set_website_theme
    theme = Theme.find(params[:theme_id])
    @website = Website.create(user_id: current_user.id, theme_id: theme.id, name: 'My Website', description: 'Description Of My Website')
    redirect_to manage_website_website_path
  end
end
