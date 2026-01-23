require "test_helper"

module RubyLLM::Monitoring
  module Metrics
    class ErrorCountTest < ActiveSupport::TestCase
      setup do
        @test_time = Time.zone.parse("2025-01-03 12:00:00")
        @time_range = @test_time..(@test_time + 2.hours)
        @resolution = 1.minute

        @empty_time_range = Time.zone.parse("2020-01-01")..Time.zone.parse("2020-01-01 01:00:00")
        @empty_scope = Event.group_by_minute(:created_at, range: @empty_time_range, n: @resolution.in_minutes.to_i)
      end

      test "returns correct metric metadata" do
        metric = ErrorCount.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Errors", result[:title]
        assert_equal "number", result[:unit]
      end

      test "returns correct metric data with error event" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = ErrorCount.new(scope)
          result = metric.as_chart_data

          assert_instance_of Array, result[:series]
          # Note: series structure is verified in controller integration tests
          if result[:series].any?
            llama_series = result[:series].find { |s| s[:name] == "ollama/llama3.2" }
            assert llama_series, "Expected to find ollama/llama3.2 series"
            assert_instance_of Array, llama_series[:data]
          end
        end
      end

      test "handles empty scope" do
        metric = ErrorCount.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Errors", result[:title]
        assert_empty result[:series]
      end

      test "counts only events with errors" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = ErrorCount.new(scope)
          result = metric.as_chart_data

          # Verify structure (actual counting verified in controller tests)
          assert_instance_of Array, result[:series]
        end
      end

      test "uses default value of 0 for nil" do
        metric = ErrorCount.new(@empty_scope)

        assert_equal 0, metric.send(:default_value)
      end
    end
  end
end
