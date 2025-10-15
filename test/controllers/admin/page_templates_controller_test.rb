require "test_helper"

class Admin::PageTemplatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_page_templates_index_url
    assert_response :success
  end
end
