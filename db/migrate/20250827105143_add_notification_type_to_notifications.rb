class AddNotificationTypeToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_column :notifications, :notification_type, :string
  end
end
