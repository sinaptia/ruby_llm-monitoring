module RubyLLM
  module Monitoring
    module Channels
      class Email < Base
        def self.deliver(message, config)
          raise ArgumentError, "Email requires :to" unless config[:to]

          RubyLLM::Monitoring::AlertMailer.with(
            to: config[:to],
            from: config[:from],
            subject: config[:subject] || "RubyLLM Monitoring Alert",
            body: message[:text]
          ).alert_notification.deliver_later
        end
      end
    end
  end
end
