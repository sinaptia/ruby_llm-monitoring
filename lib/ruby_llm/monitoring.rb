require "groupdate"
require "ruby_llm"
require "ruby_llm/instrumentation"
require "ruby_llm/monitoring/channel_registry"
require "ruby_llm/monitoring/engine"
require "ruby_llm/monitoring/version"

module RubyLLM
  module Monitoring
    module Channels
      autoload :Base, "ruby_llm/monitoring/channels/base"
      autoload :Email, "ruby_llm/monitoring/channels/email"
      autoload :Slack, "ruby_llm/monitoring/channels/slack"
    end

    module Metrics
      autoload :Base, "ruby_llm/monitoring/metrics/base"
      autoload :Cost, "ruby_llm/monitoring/metrics/cost"
      autoload :ErrorCount, "ruby_llm/monitoring/metrics/error_count"
      autoload :ResponseTime, "ruby_llm/monitoring/metrics/response_time"
      autoload :Throughput, "ruby_llm/monitoring/metrics/throughput"
    end

    autoload :EventSubscriber, "ruby_llm/monitoring/event_subscriber"

    mattr_accessor :alert_cooldown, default: 5.minutes
    mattr_accessor :alert_rules, default: []
    mattr_accessor :channel_registry, default: ChannelRegistry.new
    mattr_accessor :channels, default: {}
    mattr_accessor :importmap, default: Importmap::Map.new
    mattr_accessor :metrics, default: [
      Metrics::Throughput,
      Metrics::Cost,
      Metrics::ResponseTime,
      Metrics::ErrorCount
    ]
  end
end
