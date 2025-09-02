# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  layout "admin"


  private

  def ensure_admin!
    if current_user.role == 0

    elsif current_user.role == 1
      redirect_to manage_dashboard_path, alert: 'Access denied. Admin privileges required.'
    else
      redirect_to root_path, alert: 'Access denied. Admin privileges required.'
    end
  end


end