require "test_helper"

module RubyLLM::Monitoring
  class TimeGroupingTest < ActiveSupport::TestCase
    test "group_by_minute scopes records within range" do
      range = Time.zone.parse("2025-01-05 12:00:00")..Time.zone.parse("2025-01-05 13:00:00")
      results = Event.group_by_minute(:created_at, range: range).count

      assert results.values.all? { |v| v > 0 }
    end

    test "group_by_minute excludes records outside range" do
      range = Time.zone.parse("2020-01-01")..Time.zone.parse("2020-01-01 01:00:00")
      results = Event.group_by_minute(:created_at, range: range).count

      assert_empty results
    end

    test "group_by_minute groups into time buckets with numeric keys" do
      range = Time.zone.parse("2025-01-05 12:00:00")..Time.zone.parse("2025-01-05 13:00:00")
      results = Event.group_by_minute(:created_at, range: range).count

      results.each_key do |key|
        assert_kind_of Numeric, key, "Expected numeric bucket key, got #{key.class}"
        assert_equal 0, key.to_i % 60, "Expected bucket key to be aligned to 60-second intervals"
      end
    end

    test "group_by_minute respects n parameter for multi-minute buckets" do
      range = Time.zone.parse("2025-01-05 12:00:00")..Time.zone.parse("2025-01-05 13:00:00")
      results = Event.group_by_minute(:created_at, range: range, n: 5).count

      results.each_key do |key|
        assert_equal 0, key.to_i % 300, "Expected bucket key to be aligned to 300-second intervals"
      end
    end

    test "group_by_minute works with chained aggregations" do
      range = Time.zone.parse("2025-01-05 12:00:00")..Time.zone.parse("2025-01-05 13:00:00")
      results = Event.group_by_minute(:created_at, range: range).group(:provider, :model).count

      assert_not_empty results
      results.each_key do |(bucket, _provider, _model)|
        assert_kind_of Numeric, bucket
      end
    end

    test "raises error for unsupported adapter" do
      original_method = Event.connection.method(:adapter_name)
      Event.connection.define_singleton_method(:adapter_name) { "UnknownDB" }

      error = assert_raises(RuntimeError) do
        Event.group_by_minute(:created_at, range: 1.hour.ago..Time.current).count
      end
      assert_match(/Unsupported adapter: UnknownDB/, error.message)
    ensure
      Event.connection.define_singleton_method(:adapter_name, original_method)
    end
  end
end
