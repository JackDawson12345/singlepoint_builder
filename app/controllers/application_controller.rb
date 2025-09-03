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

  def component_types
    [
      'Header',
      'Footer',
      'Breadcrumbs',
      'Tabs',
      'Hero Section',
      'Content Section',
      'Card',
      'Article/Blog Post',
      'Image Gallery',
      'Carousel/Slider',
      'Accordion',
      'Search Bar',
      'Progress Bar',
      'Rating/Stars',
      'Comments Section',
      'Social Share Buttons',
      'Testimonial',
      'Banner',
      'Call-to-Action',
      'Products',
      'Services',
      'Blogs',
      'Service Inner',
      'Blog Inner',
      'Product Inner'
    ]
  end
end
