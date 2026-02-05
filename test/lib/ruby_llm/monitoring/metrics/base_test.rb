require "test_helper"

module RubyLLM::Monitoring
  module Metrics
    class BaseTest < ActiveSupport::TestCase
      class TestMetric < Base
        title "Test Metric"
        unit "test_unit"

        private

        def metric_data
          scope.group(:provider, :model).count
        end
      end

      setup do
        @test_time = Time.zone.parse("2025-01-01 12:00:00")
        @time_range = @test_time..(@test_time + 2.hours)
        @resolution = 1.minute

        @empty_time_range = Time.zone.parse("2020-01-01")..Time.zone.parse("2020-01-01 01:00:00")
        @empty_scope = Event.group_by_minute(:created_at, range: @empty_time_range, n: @resolution.in_minutes.to_i)
      end

      test "accepts a scope" do
        metric = TestMetric.new(@empty_scope)

        assert_equal @empty_scope, metric.scope
      end

      test "returns metric metadata" do
        metric = TestMetric.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Test Metric", result[:title]
        assert_equal "test_unit", result[:unit]
        assert result.key?(:series)
      end

      test "builds series correctly" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = TestMetric.new(scope)
          result = metric.as_chart_data

          assert_instance_of Array, result[:series]
          assert_not_empty result[:series]

          first_series = result[:series].first
          assert_equal "ollama/llama3.2", first_series[:name]
          assert_instance_of Array, first_series[:data]
          assert_instance_of Array, first_series[:data].first
          assert_equal 2, first_series[:data].first.size # [timestamp, value]
        end
      end

      test "handles empty scope" do
        metric = TestMetric.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Test Metric", result[:title]
        assert_empty result[:series]
      end

      test "raises NotImplementedError if metric_data not implemented" do
        metric = Base.new(@empty_scope)

        assert_raises(NotImplementedError) do
          metric.as_chart_data
        end
      end

      test "default_value returns nil" do
        metric = TestMetric.new(@empty_scope)

        assert_nil metric.send(:default_value)
      end
    end
  end
end
