require "net/http"
require "json"

module RubyLLM
  module Monitoring
    module Channels
      class Slack < Base
        def self.deliver(message, config)
          raise ArgumentError, "Slack requires :webhook_url" unless config[:webhook_url]

          Net::HTTP.post(URI(config[:webhook_url]), message.to_json).tap do |response|
            raise "Slack webhook failed: #{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)
          end
        end
      end
    end
  end
end
