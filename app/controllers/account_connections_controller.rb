# app/controllers/account_connections_controller.rb
class AccountConnectionsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    connection = current_user.user_connections.find(params[:id])
    provider_name = connection.provider.humanize.gsub('oauth2', '').strip

    # Security check - prevent disconnecting if it's the only way to access the account
    if current_user.encrypted_password.blank? && current_user.user_connections.count == 1
      redirect_to manage_account_settings_path,
                  alert: "Cannot disconnect #{provider_name}. Please set a password first or connect another account."
      return
    end

    connection.destroy
    redirect_to manage_account_settings_path,
                notice: "#{provider_name} account disconnected successfully."
  end
end