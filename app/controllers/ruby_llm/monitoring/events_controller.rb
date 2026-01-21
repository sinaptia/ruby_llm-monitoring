module RubyLLM::Monitoring
  class EventsController < ApplicationController
    before_action :set_event, only: %i[ show ]
    before_action :set_filters, only: %i[ index ]

    def index
      @events = Page.new Event.where(**@filters).order(created_at: :desc), page: params[:page].to_i
    end

    def show
    end

    private

    def filter_param
      {
        filter: {
          created_at_start: @filters[:created_at]&.begin.presence,
          created_at_end: @filters[:created_at]&.end.presence,
          name: @filters[:name].presence
        }
      }.compact
    end

    def set_event
      @event = Event.find params[:id]
    end

    def set_filters
      @filters = {
        created_at: (params.dig(:filter, :created_at_start).try(:in_time_zone)..params.dig(:filter, :created_at_end).try(:in_time_zone)).presence,
        name: params.dig(:filter, :name).presence
      }.compact
    end
  end
end
