require "test_helper"

class Manage::AccountSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_account_settings_index_url
    assert_response :success
  end
end
