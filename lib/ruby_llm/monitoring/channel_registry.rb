module RubyLLM
  module Monitoring
    class ChannelRegistry
      def initialize
        @registry = {}
      end

      def register(name, klass)
        @registry[name.to_sym] = klass
      end

      def fetch(name)
        @registry.fetch(name.to_sym) do
          raise ArgumentError, "Unknown channel: #{name}. Registered: #{@registry.keys.join(', ')}"
        end
      end
    end
  end
end
