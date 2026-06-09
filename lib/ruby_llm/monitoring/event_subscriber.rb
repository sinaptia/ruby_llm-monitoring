module RubyLLM
  module Monitoring
    class EventSubscriber
      FILTERED_PAYLOAD_KEYS = %i[
        chat
        input_messages
        messages_after
        model_info
        response
        result
        schema
        tool
        tool_call
        tool_calls
      ].freeze

      def call(event)
        Event.create(
          allocations: event.allocations,
          cpu_time: event.cpu_time,
          duration: event.duration,
          end: event.end,
          gc_time: event.gc_time,
          idle_time: event.idle_time,
          name: event.name,
          payload: event.payload.except(*FILTERED_PAYLOAD_KEYS).compact,
          time: event.time,
          transaction_id: event.transaction_id
        )
      end
    end
  end
end
