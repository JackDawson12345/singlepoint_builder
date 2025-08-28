require "test_helper"

class Manage::Editor::WebsiteControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get manage_editor_website_index_url
    assert_response :success
  end
end
