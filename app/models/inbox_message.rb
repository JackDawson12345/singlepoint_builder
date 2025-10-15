class InboxMessage < ApplicationRecord
  belongs_to :inbox_chat
  belongs_to :user

  def get_users_name
    [user.first_name, user.last_name].compact.join(' ').presence || user.email
  end
end
