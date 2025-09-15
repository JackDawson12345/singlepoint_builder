require "test_helper"

class Manage::Settings::Website::DomainsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_settings_website_domains_index_url
    assert_response :success
  end
end
