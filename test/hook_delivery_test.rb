require_relative "test_helper"
require_relative "../hookable"

class HookDeliveryTest < Minitest::Test

  def test_creating_a_new_delivery
    HookDelivery.create(:payload => '{"test": "data"}', :received_at => Time.now)

    assert_equal 1, HookDelivery.count
  end

end
