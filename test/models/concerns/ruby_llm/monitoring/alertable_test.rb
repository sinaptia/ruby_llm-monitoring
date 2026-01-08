require "test_helper"

module RubyLLM::Monitoring
  class AlertableTest < ActiveSupport::TestCase
    setup do
      Rails.cache.clear
      RubyLLM::Monitoring.alert_rules = []
    end

    test "evaluates alert rules when event is created" do
      triggered = false

      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { triggered = true; events.count > 0 },
          channels: [],
          message: { text: "Test alert" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert triggered
    end

    test "does not trigger alert when rule returns false" do
      triggered = false

      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { triggered = true; false },
          channels: [],
          message: { text: "Test alert" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert triggered
    end

    test "triggers alert when rule condition is met" do
      test_channel = Class.new do
        class_attribute :delivered

        def self.deliver(message, config)
          self.delivered = true
        end
      end

      RubyLLM::Monitoring.channel_registry.register :test_channel, test_channel
      RubyLLM::Monitoring.channels = { test_channel: {} }

      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { events.count > 0 },
          channels: [ :test_channel ],
          message: { text: "Test alert" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert test_channel.delivered
    end

    test "respects cooldown period" do
      call_count = 0

      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { call_count += 1; true },
          channels: [],
          message: { text: "Test alert" },
          cooldown: 5.minutes
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })
      assert_equal 1, call_count

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })
      assert_equal 1, call_count
    end

    test "uses custom cooldown when specified" do
      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { events.count > 1 },
          channels: [],
          message: { text: "Test alert" },
          cooldown: 10.minutes
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })
      assert_in_delta Time.current + 10.minutes, Rails.cache.fetch("ruby_llm-monitoring/rule_0")
    end

    test "uses default cooldown when not specified" do
      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { events.count > 1 },
          channels: [],
          message: { text: "Test alert" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })
      assert_in_delta Time.current + RubyLLM::Monitoring.alert_cooldown, Rails.cache.fetch("ruby_llm-monitoring/rule_0")
    end

    test "cooling_down? returns false when not in cooldown" do
      event = Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert_not event.send(:cooling_down?, "rule_0")
    end

    test "skips invalid alert rules" do
      call_count = 0

      RubyLLM::Monitoring.alert_rules = [
        {
          rule: ->(events) { call_count += 1; true },
          channels: [],
          message: { text: "Test alert" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert_equal 0, call_count
    end

    test "evaluates multiple alert rules" do
      call_counts = { rule1: 0, rule2: 0 }

      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { call_counts[:rule1] += 1; true },
          channels: [],
          message: { text: "Alert 1" }
        },
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { call_counts[:rule2] += 1; true },
          channels: [],
          message: { text: "Alert 2" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert_equal 1, call_counts[:rule1]
      assert_equal 1, call_counts[:rule2]
    end

    test "filters events by time_range" do
      old_event = Event.create!(
        payload: { "provider" => "ollama", "model" => "llama3.2" },
        created_at: 2.hours.ago
      )

      events_in_range = nil

      RubyLLM::Monitoring.alert_rules = [
        {
          time_range: -> { 1.hour.ago.. },
          rule: ->(events) { events_in_range = events; false },
          channels: [],
          message: { text: "Test alert" }
        }
      ]

      Event.create!(payload: { "provider" => "ollama", "model" => "llama3.2" })

      assert_not_includes events_in_range.to_a, old_event
    end
  end
end
