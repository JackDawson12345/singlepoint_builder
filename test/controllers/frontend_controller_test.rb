require "test_helper"

class FrontendControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get frontend_home_url
    assert_response :success
  end

  test "should get about" do
    get frontend_about_url
    assert_response :success
  end

  test "should get themes" do
    get frontend_themes_url
    assert_response :success
  end

  test "should get contact" do
    get frontend_contact_url
    assert_response :success
  end
end
