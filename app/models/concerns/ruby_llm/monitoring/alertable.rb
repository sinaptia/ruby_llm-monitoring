module RubyLLM
  module Monitoring
    module Alertable
      extend ActiveSupport::Concern

      included do
        after_create_commit :evaluate_alert_rules
      end

      private

      def cooldown(rule_id, custom_cooldown)
        ttl = custom_cooldown || RubyLLM::Monitoring.alert_cooldown

        Rails.cache.write("ruby_llm-monitoring/#{rule_id}", Time.current + ttl, expires_in: ttl)
      end

      def cooling_down?(rule_id)
        Rails.cache.exist?("ruby_llm-monitoring/#{rule_id}")
      end

      def dispatch_to_channels(alert_rule)
        alert_rule[:channels].each do |channel_name|
          channel = RubyLLM::Monitoring.channel_registry.fetch(channel_name)
          channel_config = RubyLLM::Monitoring.channels[channel_name] || {}
          channel.deliver(alert_rule[:message], channel_config)
        rescue => e
          Rails.logger.error "[RubyLLM::Monitoring] Failed to deliver alert to #{channel_name}: #{e.message}"
        end
      end

      def evaluate_alert_rules
        RubyLLM::Monitoring.alert_rules.each_with_index do |alert_rule, index|
          rule_id = "rule_#{index}"

          next unless valid_alert_rule?(alert_rule)
          next if cooling_down?(rule_id)

          events = self.class.where(created_at: alert_rule[:time_range].call)

          if alert_rule[:rule].call(events)
            cooldown(rule_id, alert_rule[:cooldown])
            dispatch_to_channels(alert_rule)
          end
        end
      end

      def valid_alert_rule?(alert_rule)
        alert_rule[:time_range].respond_to?(:call) && alert_rule[:rule].respond_to?(:call) && alert_rule[:channels].is_a?(Array) && alert_rule[:message].is_a?(Hash)
      end
    end
  end
end
