require "test_helper"

class Admin::ThemePagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_theme_pages_index_url
    assert_response :success
  end
end
