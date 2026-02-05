module RubyLLM
  module Monitoring
    class EventSubscriber
      def call(event)
        Event.create(
          allocations: event.allocations,
          cpu_time: event.cpu_time,
          duration: event.duration,
          end: event.end,
          gc_time: event.gc_time,
          idle_time: event.idle_time,
          name: event.name,
          payload: clean_payload(event.payload),
          time: event.time,
          transaction_id: event.transaction_id
        )
      end

      private

      def clean_payload(payload)
        payload.tap do |p|
          p[:chat]&.messages&.each(&:clear!)
        end
      end
    end
  end
end
