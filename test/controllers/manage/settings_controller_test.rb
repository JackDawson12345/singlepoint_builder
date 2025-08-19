require "test_helper"

class Manage::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_settings_index_url
    assert_response :success
  end
end
