require "test_helper"

class Admin::ComponentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_components_index_url
    assert_response :success
  end
end
