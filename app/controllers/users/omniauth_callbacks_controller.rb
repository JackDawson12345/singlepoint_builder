# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_omniauth_callback('Google')
  end

  def facebook
    handle_omniauth_callback('Facebook')
  end

  def failure
    if user_signed_in?
      redirect_to manage_account_settings_path,
                  alert: "Authentication failed. Please try again."
    else
      redirect_to root_path, alert: "Authentication failed."
    end
  end

  private

  def handle_omniauth_callback(provider_name)
    auth = request.env["omniauth.auth"]

    if user_signed_in?
      link_account(auth, provider_name)
    else
      authenticate_user(auth, provider_name)
    end
  end

  def link_account(auth, provider_name)
    existing_connection = current_user.user_connections.find_by(provider: auth.provider)

    if existing_connection
      redirect_to manage_account_settings_path,
                  notice: "#{provider_name} account is already connected to your account."
    else
      other_connection = UserConnection.find_by(provider: auth.provider, uid: auth.uid)

      if other_connection && other_connection.user != current_user
        redirect_to manage_account_settings_path,
                    alert: "This #{provider_name} account is already connected to another user account."
      else
        current_user.user_connections.create!(
          provider: auth.provider,
          uid: auth.uid,
          name: auth.info.name,
          email: auth.info.email,
          image: auth.info.image
        )
        redirect_to manage_account_settings_path,
                    notice: "#{provider_name} account successfully connected!"
      end
    end
  end

  def authenticate_user(auth, provider_name)
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      session["devise.#{auth.provider}_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end