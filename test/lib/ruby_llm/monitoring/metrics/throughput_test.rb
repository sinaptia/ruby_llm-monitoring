require "test_helper"

module RubyLLM::Monitoring
  module Metrics
    class ThroughputTest < ActiveSupport::TestCase
      setup do
        @test_time = Time.zone.parse("2025-01-05 12:00:00")
        @time_range = @test_time..(@test_time + 2.hours)
        @resolution = 1.minute

        @empty_time_range = Time.zone.parse("2020-01-01")..Time.zone.parse("2020-01-01 01:00:00")
        @empty_scope = Event.group_by_minute(:created_at, range: @empty_time_range, n: @resolution.in_minutes.to_i)
      end

      test "returns correct metric metadata" do
        metric = Throughput.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Throughput", result[:title]
        assert_nil result[:unit]
      end

      test "returns correct metric data with multiple events" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = Throughput.new(scope)
          result = metric.as_chart_data

          assert_instance_of Array, result[:series]
          assert_not_empty result[:series]

          llama_series = result[:series].find { |s| s[:name] == "ollama/llama3.2" }
          assert llama_series, "Expected to find ollama/llama3.2 series"
          assert_instance_of Array, llama_series[:data]
          assert_operator llama_series[:data].size, :>=, 2
        end
      end

      test "handles empty scope" do
        metric = Throughput.new(@empty_scope)
        result = metric.as_chart_data

        assert_equal "Throughput", result[:title]
        assert_empty result[:series]
      end

      test "counts requests correctly" do
        travel_to @test_time do
          scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)
          metric = Throughput.new(scope)
          result = metric.as_chart_data

          assert_not_empty result[:series]
          gemma_series = result[:series].find { |s| s[:name] == "ollama/gemma3" }
          assert gemma_series, "Expected to find ollama/gemma3 series"
          gemma_count = calculate_total_from_series([ gemma_series ])
          assert_equal 3, gemma_count
        end
      end

      private

      def calculate_total_from_series(series)
        series.sum { |s| s[:data].sum { |(_, value)| value || 0 } }
      end
    end
  end
end
