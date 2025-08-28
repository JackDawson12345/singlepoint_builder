require "test_helper"

class Admin::Website::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index.html.erb" do
    get admin_website_products_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_website_products_edit_url
    assert_response :success
  end

  test "should get new" do
    get admin_website_products_new_url
    assert_response :success
  end
end
