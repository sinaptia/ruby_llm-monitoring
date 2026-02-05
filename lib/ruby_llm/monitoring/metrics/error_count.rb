module RubyLLM::Monitoring
  module Metrics
    class ErrorCount < Base
      title "Errors"
      unit "number"

      private

      def metric_data
        scope.group(:provider, :model).where("exception_class IS NOT NULL").count
      end

      def default_value
        0
      end
    end
  end
end
