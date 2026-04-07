module RubyLLM::Monitoring
  class Event < ApplicationRecord
    include Alertable

    before_validation :set_cost

    private

    def set_cost
      return self.cost = 0.0 if [ payload["input_tokens"], payload["output_tokens"] ].all?(nil)

      model = RubyLLM::Models.find(payload["model"], payload["provider"])

      input_cost = payload["input_tokens"].to_f / 1_000_000.0 * model.input_price_per_million.to_f
      output_cost = payload["output_tokens"].to_f / 1_000_000.0 * model.output_price_per_million.to_f
      thinking_cost = payload["thinking_tokens"].to_f / 1_000_000.0 * model.output_price_per_million.to_f

      self.cost = input_cost + output_cost + thinking_cost
    rescue RubyLLM::ModelNotFoundError
      self.cost = 0.0
    end
  end
end
