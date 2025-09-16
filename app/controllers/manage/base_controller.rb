# app/controllers/admin/base_controller.rb
class Manage::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_manage!
  before_action :has_website


  layout 'manage'


  private

  def ensure_manage!
    if current_user.role == 1

    elsif current_user.role == 0
      redirect_to admin_dashboard_path, alert: 'Access denied. Manage privileges required.'
    else
      redirect_to root_path, alert: 'Access denied. Manage privileges required.'
    end
  end

  def has_website
    unless current_user.website
      redirect_to manage_setup_path, alert: 'Please Set Up Your Website.'
    end
  end
end