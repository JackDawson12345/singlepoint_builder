require "test_helper"

class Admin::Website::WebsiteControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get admin_website_website_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_website_website_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_website_website_edit_url
    assert_response :success
  end

  test "should get new" do
    get admin_website_website_new_url
    assert_response :success
  end
end
