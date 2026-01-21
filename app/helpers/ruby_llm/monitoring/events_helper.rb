module RubyLLM::Monitoring
  module EventsHelper
    def event_name_options
      Event.pluck(:name).uniq.index_by &:itself
    end
  end
end
