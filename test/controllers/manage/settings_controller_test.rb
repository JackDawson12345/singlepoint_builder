require "test_helper"

class Manage::SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get manage_settings_index_url
    assert_response :success
  end
end
