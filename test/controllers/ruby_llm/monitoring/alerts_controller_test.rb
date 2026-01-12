require "test_helper"

module RubyLLM::Monitoring
  class AlertsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      RubyLLM::Monitoring.alert_rules = []
    end

    test "should get index" do
      get alerts_url
      assert_response :success
    end
  end
end
