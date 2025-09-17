# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  prepend_before_action :authenticate_with_two_factor, if: :two_factor_enabled?, only: [:create]
  after_action :track_login_activity, only: [:create]

  layout 'frontend'

  private

  def two_factor_enabled?
    find_user&.otp_required_for_login
  end

  def authenticate_with_two_factor
    user = find_user
    if user_params[:otp_attempt].present?
      authenticate_with_two_factor_via_otp(user)
    else
      session[:otp_user_id] = user.id
      session[:temp_password] = user_params[:password]  # Store temporarily
      redirect_to two_factor_path
    end
  end

  def two_factor
    @request.env["devise.mapping"] = Devise.mappings[:user]

    if session[:otp_user_id]
      @user = User.find(session[:otp_user_id])
    else
      redirect_to new_user_session_path, alert: 'Session expired. Please log in again.'
      return
    end

    # Debug: Check if user is found
    Rails.logger.info "2FA page: User found: #{@user&.email}"
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      session.delete(:otp_user_id)
      session.delete(:temp_password)
      sign_in(user)
    else
      # Use flash[:alert] instead of flash.now[:alert] for redirects
      flash[:alert] = 'Invalid authentication code. Please try again.'
      redirect_to two_factor_path
    end
  end


  def prompt_for_two_factor(user)
    @user = user
    request.format = :html
    render 'two_factor_authentication', layout: 'application'
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt]) ||
      user.invalidate_otp_backup_code!(user_params[:otp_attempt])
  end

  def find_user
    if session[:otp_user_id]
      User.find(session[:otp_user_id])
    elsif user_params[:email]
      user = User.find_for_authentication(email: user_params[:email])
      if user&.valid_password?(user_params[:password])
        session[:otp_user_id] = user.id
        user
      end
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :otp_attempt, :remember_me)
  end

  def track_login_activity
    return unless user_signed_in?

    LoginActivityTracker.track(current_user, request)
  end
end