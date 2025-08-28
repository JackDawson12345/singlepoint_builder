class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def notify_all_admins(message, notification_type = 'announcement')
    admin_users = User.where(role: 0) # or User.admin if using enum

    notification_data = admin_users.map do |user|
      {
        user_id: user.id,
        message: message,
        notification_type: notification_type,
        read: false,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Notification.insert_all(notification_data)
  end
end
