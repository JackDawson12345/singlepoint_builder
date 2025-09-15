require "test_helper"

class Manage::Website::Shop::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_website_shop_products_index_url
    assert_response :success
  end
end
