require "test_helper"

class Manage::Settings::HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_settings_home_index_url
    assert_response :success
  end
end
