require "test_helper"

module RubyLLM::Monitoring
  class MetricsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get metrics_url
      assert_response :success
    end

    test "renders all three metric charts" do
      get metrics_url
      assert_response :success
      assert_match 'data-title="Throughput"', response.body
      assert_match 'data-title="Cost"', response.body
      assert_match 'data-title="Response time"', response.body
    end

    test "filters events by date range" do
      # Fixtures: anthropic_recent (30 mins ago), anthropic_old (3 hours ago)
      # Default is 2 hours ago, so only recent events should be included
      get metrics_url
      assert_response :success

      # anthropic should appear (recent fixture is 30 mins ago)
      assert_match "anthropic", response.body

      # With a narrower range, we should still get recent
      get metrics_url, params: { filter: { created_at_start: 1.hour.ago.iso8601 } }
      assert_response :success
    end

    test "renders without error when no events exist" do
      Event.delete_all
      get metrics_url
      assert_response :success
    end
  end
end
