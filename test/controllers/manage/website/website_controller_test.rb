require "test_helper"

class Manage::Website::WebsiteControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_website_website_index_url
    assert_response :success
  end
end
