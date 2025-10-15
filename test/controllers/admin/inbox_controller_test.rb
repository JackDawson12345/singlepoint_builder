require "test_helper"

class Admin::InboxControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_inbox_index_url
    assert_response :success
  end
end
