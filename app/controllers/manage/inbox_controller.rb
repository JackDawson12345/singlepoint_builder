class Manage::InboxController < Manage::BaseController
  def index
    @chats = InboxChat.where(user_id: current_user.id).order(updated_at: :desc)

    # Get last message for each chat
    @chat_data = {}
    @chats.each do |chat|
      last_message = InboxMessage.where(inbox_chat_id: chat.id).order(created_at: :desc).first
      if last_message
        message_text = last_message.message
        preview = message_text.length > 25 ? message_text[0..24] + '...' : message_text
        @chat_data[chat.id] = {
          preview: preview,
          time: last_message.created_at.strftime('%I:%M%p'),
          unread_count: 0 # You can implement unread logic later
        }
      else
        @chat_data[chat.id] = {
          preview: 'No messages yet',
          time: chat.created_at.strftime('%I:%M%p'),
          unread_count: 0
        }
      end
    end
  end

  def get_message
    chat = InboxChat.find(params[:chat_id])
    chatOpenDate = chat.created_at
    chatOpenDateFormat = chatOpenDate.day.ordinalize + ' ' + chatOpenDate.strftime('%B %Y at %I:%M%p')
    messages = InboxMessage.where(inbox_chat_id: chat.id).order(created_at: :asc)

    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            partial: 'manage/inbox/inbox_messages',
            locals: { chat: chat, date: chatOpenDateFormat, messages: messages },
            formats: [:html],
            layout: false
          )
        }
      end
    end
  end

  def get_new_chat
    chatOpenDate = Time.now
    chatOpenDateFormat = chatOpenDate.day.ordinalize + ' ' + chatOpenDate.strftime('%B %Y at %I:%M%p')

    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            partial: 'manage/inbox/new_inbox_message',
            locals: { date: chatOpenDateFormat },
            formats: [:html],
            layout: false
          )
        }
      end
    end
  end

  def new_chat_message
    user = current_user
    @inboxChat = InboxChat.create(user_id: user.id)
    @inboxMessage = InboxMessage.create(
      inbox_chat_id: @inboxChat.id,
      user_id: user.id,
      message: params[:message]
    )

    # Return the updated chat view
    chatOpenDate = @inboxChat.created_at
    chatOpenDateFormat = chatOpenDate.day.ordinalize + ' ' + chatOpenDate.strftime('%B %Y at %I:%M%p')
    messages = InboxMessage.where(inbox_chat_id: @inboxChat.id).order(created_at: :asc)

    # Get the last message preview (25 characters)
    lastMessage = @inboxMessage.message
    lastMessagePreview = lastMessage.length > 25 ? lastMessage[0..24] + '...' : lastMessage

    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            partial: 'manage/inbox/inbox_messages',
            locals: { chat: @inboxChat, date: chatOpenDateFormat, messages: messages },
            formats: [:html],
            layout: false
          ),
          chat_data: {
            id: @inboxChat.id,
            message_preview: lastMessagePreview,
            time: @inboxMessage.created_at.strftime('%I:%M%p'),
            unread_count: 0
          }
        }
      end
    end
  end

  def old_chat_message
    user = current_user
    @inboxChat = InboxChat.find(params[:chat_id])
    @inboxChat.touch # Update the updated_at timestamp

    @inboxMessage = InboxMessage.create(
      inbox_chat_id: @inboxChat.id,
      user_id: user.id,
      message: params[:message]
    )

    # Return the updated chat view
    chatOpenDate = @inboxChat.created_at
    chatOpenDateFormat = chatOpenDate.day.ordinalize + ' ' + chatOpenDate.strftime('%B %Y at %I:%M%p')
    messages = InboxMessage.where(inbox_chat_id: @inboxChat.id).order(created_at: :asc)

    respond_to do |format|
      format.json do
        render json: {
          html: render_to_string(
            partial: 'manage/inbox/inbox_messages',
            locals: { chat: @inboxChat, date: chatOpenDateFormat, messages: messages },
            formats: [:html],
            layout: false
          )
        }
      end
    end
  end
end