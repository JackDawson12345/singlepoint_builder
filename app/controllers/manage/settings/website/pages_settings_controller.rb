class Manage::Settings::Website::PagesSettingsController < Manage::BaseController
  def index
    @pages = current_user.website.pages['theme_pages']
  end
end
