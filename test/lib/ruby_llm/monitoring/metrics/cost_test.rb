require "test_helper"

module RubyLLM::Monitoring
  module Metrics
    class CostTest < ActiveSupport::TestCase
      setup do
        @test_time = Time.zone.parse("2025-01-02 12:00:00")
        @time_range = @test_time..(@test_time + 2.hours)
        @resolution = 1.minute

        @empty_time_range = Time.zone.parse("2020-01-01")..Time.zone.parse("2020-01-01 01:00:00")
        @empty_scope = Event.group_by_minute(:created_at, range: @empty_time_range, n: @resolution.in_minutes.to_i)
      end

      test "returns correct metric metadata" do
        metric = Cost.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Cost", result[:title]
        assert_equal "money", result[:unit]
      end

      test "returns correct metric data with multiple events" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = Cost.new(scope)
          result = metric.as_chart_data

          assert_instance_of Array, result[:series]
          assert_not_empty result[:series]

          first_series = result[:series].first
          assert_equal "ollama/llama3.2", first_series[:name]
          assert_instance_of Array, first_series[:data]
        end
      end

      test "handles empty scope" do
        metric = Cost.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Cost", result[:title]
        assert_empty result[:series]
      end

      test "sums costs correctly" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = Cost.new(scope)
          result = metric.as_chart_data

          assert_not_empty result[:series]
          total_cost = calculate_total_from_series(result[:series])
          assert_operator total_cost, :>=, 0
        end
      end

      private

      def calculate_total_from_series(series)
        series.sum { |s| s[:data].sum { |(_, value)| value || 0 } }
      end
    end
  end
end
