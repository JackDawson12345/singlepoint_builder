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

    byebug

    if @website.favicon.attached?
      result = @website.favicon.purge
    end

    redirect_to manage_website_settings_path, notice: 'Favicon removed successfully.'
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace
    redirect_to manage_website_settings_path, alert: "Error removing favicon: #{e.message}"
  end

  def update_website_name
    if current_user.website.update(name: params[:site_name])
      flash.now[:notice] = "Website name updated successfully"
      status = 'success'
    else
      flash.now[:alert] = "Failed to update website name"
      status = 'error'
    end

    render json: {
      status: status,
      message: flash.now[:notice] || flash.now[:alert],
      flash_type: flash.now[:notice] ? 'notice' : 'alert'
    }
  end

  private

  def set_website
    @website = current_user.website
  end

  def website_params
    params.require(:website).permit(:favicon, :name, :url) # add other permitted attributes as needed
  end
end