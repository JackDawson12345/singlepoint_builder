require "test_helper"

class Manage::Website::WebisteControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get manage_website_webiste_index_url
    assert_response :success
  end
end
