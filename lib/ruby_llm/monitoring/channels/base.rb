module RubyLLM
  module Monitoring
    module Channels
      class Base
        def self.deliver(message, config)
          raise NotImplementedError
        end
      end
    end
  end
end
