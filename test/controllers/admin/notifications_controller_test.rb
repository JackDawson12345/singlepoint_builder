require "test_helper"

class Admin::NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get admin_notifications_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_notifications_show_url
    assert_response :success
  end
end
