module RubyLLM::Monitoring
  class MetricsController < ApplicationController
    before_action :set_resolution
    before_action :set_time_range

    def index
      base_scope = Event.group_by_minute(:created_at, range: @time_range, n: @resolution.in_minutes.to_i)

      @metrics = RubyLLM::Monitoring.metrics.map do |klass|
        klass.new(base_scope).as_chart_data
      end

      @totals_by_provider = Event.where(created_at: @time_range)
        .group(:provider, :model)
        .select(
          :provider,
          :model,
          "COUNT(*) as requests",
          "SUM(cost) as cost",
          "AVG(duration) as avg_response_time",
          "SUM(CASE WHEN exception_class IS NOT NULL THEN 1 ELSE 0 END) as error_count"
        ).to_a

      total_requests = @totals_by_provider.sum(&:requests)
      error_count = @totals_by_provider.sum(&:error_count)

      @totals = {
        requests: total_requests,
        cost: @totals_by_provider.sum { |r| r.cost.to_f },
        avg_response_time: @totals_by_provider.any? ? @totals_by_provider.sum do |r|
          r.avg_response_time.to_f * r.requests
        end / total_requests : nil,
        error_rate: total_requests.positive? ? (error_count.to_f / total_requests * 100).round(1) : 0
      }
    end

    private

    def filter_param
      {
        filter: {
          created_at_start: @created_at_start,
          created_at_end: @created_at_end,
          resolution: @resolution
        }
      }.compact
    end

    def set_resolution
      @resolution = params.dig(:filter, :resolution).try(:to_i).try(:minutes) || 1.minute
    end

    def set_time_range
      @created_at_start = params.dig(:filter, :created_at_start).try(:in_time_zone) || 2.hours.ago
      @created_at_end = params.dig(:filter, :created_at_end).try(:in_time_zone)

      @time_range = @created_at_start..@created_at_end
    end
  end
end
