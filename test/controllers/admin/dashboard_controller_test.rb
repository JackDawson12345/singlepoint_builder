require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get admin_dashboard_index_url
    assert_response :success
  end
end
