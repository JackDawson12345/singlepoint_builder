require "test_helper"

class Manage::Website::Editor::WebsiteEditorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_website_editor_website_editor_index_url
    assert_response :success
  end
end
