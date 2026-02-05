module RubyLLM::Monitoring
  module Metrics
    class Cost < Base
      title "Cost"
      unit "money"

      private

      def metric_data
        scope.group(:provider, :model).sum(:cost)
      end
    end
  end
end
