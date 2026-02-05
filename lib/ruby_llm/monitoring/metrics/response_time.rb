module RubyLLM::Monitoring
  module Metrics
    class ResponseTime < Base
      title "Response time"
      unit "ms"

      private

      def metric_data
        scope.group(:provider, :model).average(:duration)
      end

      def default_value
        0
      end
    end
  end
end
