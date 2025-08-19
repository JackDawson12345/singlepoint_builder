require "test_helper"

class Manage::Editor::WebsiteEditorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_editor_website_editor_index_url
    assert_response :success
  end
end
