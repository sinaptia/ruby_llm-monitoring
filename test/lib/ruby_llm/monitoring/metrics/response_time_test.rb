require "test_helper"

module RubyLLM::Monitoring
  module Metrics
    class ResponseTimeTest < ActiveSupport::TestCase
      setup do
        @test_time = Time.zone.parse("2025-01-04 12:00:00")
        @time_range = @test_time..(@test_time + 2.hours)
        @resolution = 1.minute

        @empty_time_range = Time.zone.parse("2020-01-01")..Time.zone.parse("2020-01-01 01:00:00")
        @empty_scope = Event.group_by_minute(:created_at, range: @empty_time_range, n: @resolution.in_minutes.to_i)
      end

      test "returns correct metric metadata" do
        metric = ResponseTime.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Response time", result[:title]
        assert_equal "ms", result[:unit]
      end

      test "returns correct metric data with multiple events" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = ResponseTime.new(scope)
          result = metric.as_chart_data

          assert_instance_of Array, result[:series]
          assert_not_empty result[:series]

          llama_series = result[:series].find { |s| s[:name] == "ollama/llama3.2" }
          assert llama_series, "Expected to find ollama/llama3.2 series"
          assert_instance_of Array, llama_series[:data]
        end
      end

      test "handles empty scope" do
        metric = ResponseTime.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Response time", result[:title]
        assert_empty result[:series]
      end

      test "averages duration correctly" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = ResponseTime.new(scope)
          result = metric.as_chart_data

          assert_not_empty result[:series]
          first_series = result[:series].first
          first_series[:data].each do |_timestamp, value|
            assert_kind_of Numeric, value
            assert_operator value, :>=, 0
          end
        end
      end

      test "uses default value of 0 for nil" do
        metric = ResponseTime.new(@empty_scope)

        assert_equal 0, metric.send(:default_value)
      end
    end
  end
end
