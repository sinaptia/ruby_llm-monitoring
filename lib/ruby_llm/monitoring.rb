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

    autoload :EventSubscriber, "ruby_llm/monitoring/event_subscriber"

    mattr_accessor :alert_cooldown, default: 5.minutes
    mattr_accessor :alert_rules, default: []
    mattr_accessor :channel_registry, default: ChannelRegistry.new
    mattr_accessor :channels, default: {}
    mattr_accessor :importmap, default: Importmap::Map.new
  end
end
