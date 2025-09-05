class Manage::SettingsController < Manage::BaseController
  before_action :set_website, only: [:website_settings, :update_website, :remove_favicon]

  def index
  end

  def website_settings
    # @website is already set by before_action
  end

  def update_website
    if @website.update(website_params)
      redirect_to manage_website_settings_path, notice: 'Website settings updated successfully.'
    else
      render :website_settings
    end
  end

  def remove_favicon
    @website.favicon.purge
    redirect_to manage_website_settings_path, notice: 'Favicon removed successfully.'
  end

  private

  def set_website
    @website = current_user.website
  end

  def website_params
    params.require(:website).permit(:favicon, :name, :url) # add other permitted attributes as needed
  end
end