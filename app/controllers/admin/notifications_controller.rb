class Admin::NotificationsController < Admin::BaseController
  def index
    @notifications = Notification.where(user_id: current_user.id)
  end

  def show
    @notification = Notification.find(params[:id])
  end

  def read
    @notification = Notification.find(params[:id])
    @notification.update(read: true)
    redirect_to admin_notifications_path, notice: 'Notification was successfully marked as read.'
  end
end
