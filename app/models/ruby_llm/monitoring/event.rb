module RubyLLM::Monitoring
  class Event < ApplicationRecord
    include Alertable

    before_validation :set_cost

    private

    def set_cost
      return self.cost = 0.0 if [ payload["input_tokens"], payload["output_tokens"] ].all?(nil)

      model, provider = RubyLLM.models.resolve payload["model"], provider: payload["provider"]
      return self.cost = 0.0 if provider.nil? || provider.local?

      input_cost = payload["input_tokens"].to_f / 1_000_000.0 * model.input_price_per_million.to_f
      output_cost = payload["output_tokens"].to_f / 1_000_000.0 * model.output_price_per_million.to_f
      thinking_cost = payload["thinking_tokens"].to_f / 1_000_000.0 * model.output_price_per_million.to_f

      self.cost = input_cost + output_cost + thinking_cost
    end
  end
end
