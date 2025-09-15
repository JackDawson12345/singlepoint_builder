require "test_helper"

class Manage::Website::Shop::ProductCategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_website_shop_product_categories_index_url
    assert_response :success
  end
end
