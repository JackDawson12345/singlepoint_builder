class Manage::AccountSettingsController < Manage::BaseController
  def index
    @user = current_user
  end

  def update
    @user = current_user

    # Handle profile image removal
    if params[:remove_profile_image] == "1"
      @user.profile_image.purge
    end

    # Update user attributes
    if @user.update(account_settings_params)
      respond_to do |format|
        format.json { render json: { status: 'success', message: 'Account updated successfully!' } }
        format.html { redirect_to manage_account_settings_path, notice: 'Account updated successfully!' }
      end
    else
      respond_to do |format|
        format.json { render json: { status: 'error', errors: @user.errors.full_messages } }
        format.html { redirect_to manage_account_settings_path, alert: @user.errors.full_messages.join(', ') }
      end
    end
  end

  def update_password
    if current_user.valid_password?(params[:current_password])
      if current_user.update(password: params[:new_password], password_confirmation: params[:confirm_password])
        render json: { success: true }
      else
        render json: { success: false, message: current_user.errors.full_messages.join(', ') }
      end
    else
      render json: { success: false, message: 'Current password is incorrect' }
    end
  end

  private

  def account_settings_params
    params.permit(:first_name, :last_name, :site_url_prefix, :account_language, :profile_image)
  end
end
