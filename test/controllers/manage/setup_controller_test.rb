require "test_helper"

class Manage::SetupControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get manage_setup_index_url
    assert_response :success
  end
end
