module RubyLLM::Monitoring
  class Event < ApplicationRecord
    include Alertable

    before_validation :set_cost

    private

    def set_cost
      model, provider = RubyLLM.models.resolve payload["model"], provider: payload["provider"]

      self.cost = if provider.local? || [ payload["input_tokens"], payload["output_tokens"] ].all?(nil)
        0.0
      else
        input_cost = payload["input_tokens"] / 1_000_000.0 * model.input_price_per_million
        output_cost = payload["output_tokens"] / 1_000_000.0 * model.output_price_per_million

        input_cost + output_cost
      end
    end
  end
end
