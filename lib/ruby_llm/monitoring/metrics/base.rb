module RubyLLM::Monitoring
  module Metrics
    class Base
      attr_reader :scope

      def initialize(scope)
        @scope = scope
      end

      def as_chart_data
        {
          title: self.class.title,
          unit: self.class.unit,
          series: build_series(metric_data)
        }.compact
      end

      private

      def metric_data
        raise NotImplementedError
      end

      def build_series(aggregated_data)
        aggregated_data
          .group_by { |(_, provider, model), _| [ provider, model ] }
          .reject { |keys, _| keys.all?(&:nil?) }
          .transform_values do |entries|
            entries.map do |(timestamp, _, _), value|
              [ timestamp.to_i * 1000, value || default_value ]
            end
          end
          .map { |keys, data| { name: keys.join("/"), data: data } }
      end

      def default_value
        nil
      end

      class << self
        def title(value = nil)
          value ? @title = value : @title
        end

        def unit(value = nil)
          value ? @unit = value : @unit
        end
      end
    end
  end
end
