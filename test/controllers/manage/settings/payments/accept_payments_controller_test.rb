require "test_helper"

class Manage::Settings::Payments::AcceptPaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_settings_payments_accept_payments_index_url
    assert_response :success
  end
end
