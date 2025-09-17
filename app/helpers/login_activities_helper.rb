# app/helpers/login_activities_helper.rb
module LoginActivitiesHelper
  def device_icon(device)
    case device.downcase
    when 'mobile'
      'fas fa-mobile-alt'
    when 'tablet'
      'fas fa-tablet-alt'
    else
      'fas fa-desktop'
    end
  end
end