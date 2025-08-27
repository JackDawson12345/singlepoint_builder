require "test_helper"

class Manage::Website::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_website_products_index_url
    assert_response :success
  end
end
