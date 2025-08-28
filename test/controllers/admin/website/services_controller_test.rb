require "test_helper"

class Admin::Website::ServicesControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get admin_website_services_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_website_services_edit_url
    assert_response :success
  end

  test "should get new" do
    get admin_website_services_new_url
    assert_response :success
  end
end
