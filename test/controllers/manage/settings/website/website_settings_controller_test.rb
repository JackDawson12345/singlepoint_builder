require "test_helper"

class Manage::Settings::Website::WebsiteSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_settings_website_website_settings_index_url
    assert_response :success
  end
end
