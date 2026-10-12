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
          payload: normalized_payload(event.payload),
          time: event.time,
          transaction_id: event.transaction_id
        )
      end

      private

      # ruby_llm >= 2.x reports usage as nested `tokens`/`cost` objects instead
      # of top-level `input_tokens`/`output_tokens`. Flatten them so the stored
      # payload — and the SQL virtual columns derived from it — stay queryable
      # and Event#set_cost can price them.
      def normalized_payload(raw)
        payload = raw.stringify_keys.except(*FILTERED_PAYLOAD_KEYS.map(&:to_s))
        payload.merge!(normalized_token_counts(payload.delete("tokens")))
        payload["cost"] = serialized_cost(payload["cost"])
        payload.compact
      end

      def normalized_token_counts(tokens)
        return {} unless tokens.respond_to?(:to_h)

        counts = tokens.to_h.stringify_keys
        %w[input output thinking].each do |name|
          short = counts.delete(name)
          counts["#{name}_tokens"] = short if !short.nil? && counts["#{name}_tokens"].nil?
        end
        counts
      end

      def serialized_cost(cost)
        return cost if cost.nil? || !cost.respond_to?(:to_h)

        cost.to_h
      end
    end
  end
end
