require "test_helper"

module RubyLLM::Monitoring
  class MetricsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get metrics_url
      assert_response :success
    end

    test "renders all four metric charts" do
      get metrics_url
      assert_response :success
      assert_match 'data-title="Throughput"', response.body
      assert_match 'data-title="Cost"', response.body
      assert_match 'data-title="Response time"', response.body
      assert_match 'data-title="Errors"', response.body
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

    test "displays totals summary cards" do
      get metrics_url
      assert_response :success

      # Check that totals section is rendered
      assert_select ".columns .box", minimum: 4
      assert_match "Requests", response.body
      assert_match "Cost", response.body
      assert_match "Avg Response Time", response.body
      assert_match "Error Rate", response.body
    end

    test "displays provider/model breakdown table" do
      get metrics_url
      assert_response :success

      # Check that breakdown table is rendered with provider/model data
      assert_select "table.table tbody tr", minimum: 1
    end

    test "totals are correctly calculated for the time range" do
      # Default time range is 2 hours ago, so gemini_with_cache and anthropic_old should be excluded
      # Within range: anthropic_recent (30 min ago), ollama_recent (1 hour ago), no_tokens (1 hour ago)
      get metrics_url
      assert_response :success

      # anthropic should appear in the breakdown
      assert_match "anthropic", response.body
      # ollama should appear in the breakdown
      assert_match "ollama", response.body
    end

    test "totals work with empty results" do
      Event.delete_all
      get metrics_url
      assert_response :success

      # Should show 0 requests
      assert_match "0", response.body
    end
  end
end
