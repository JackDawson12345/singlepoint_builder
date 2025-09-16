class Manage::AccountSettingsController < Manage::BaseController
  def show
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

  def generate_2fa_secret
    # Remove this line - it's causing the error:
    # current_user.otp_secret = User.generate_otp_secret

    # Just call the instance method - it will generate if needed:
    qr_code = build_qr_code

    render json: {
      success: true,
      qr_code: qr_code,
      secret: current_user.otp_secret
    }
  end

  def enable_2fa
    if current_user.validate_and_consume_otp!(params[:otp_attempt])
      current_user.update!(otp_required_for_login: true)
      backup_codes = current_user.generate_two_factor_backup_codes!

      render json: {
        success: true,
        backup_codes: backup_codes,
        message: 'Two-factor authentication enabled successfully'
      }
    else
      render json: {
        success: false,
        message: 'Invalid code. Please try again.'
      }
    end
  end

  private

  def account_settings_params
    params.permit(:first_name, :last_name, :site_url_prefix, :account_language, :profile_image)
  end

  def build_qr_code
    issuer = 'YourAppName' # Replace with your actual app name
    label = "#{issuer}:#{current_user.email}"

    qr_code = RQRCode::QRCode.new(current_user.otp_provisioning_uri(label, issuer: issuer))
    qr_code.as_svg(module_size: 4)
  end
end