module RubyLLM::Monitoring
  module Metrics
    class Throughput < Base
      title "Throughput"
      unit nil

      private

      def metric_data
        scope.group(:provider, :model).count
      end
    end
  end
end
