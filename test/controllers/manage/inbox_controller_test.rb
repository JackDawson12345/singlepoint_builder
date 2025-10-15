require "test_helper"

class Manage::InboxControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_inbox_index_url
    assert_response :success
  end
end
