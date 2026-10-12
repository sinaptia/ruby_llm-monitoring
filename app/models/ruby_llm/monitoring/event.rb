module RubyLLM::Monitoring
  class Event < ApplicationRecord
    include Alertable

    before_validation :set_cost

    private

    def set_cost
      return self.cost = 0.0 if [ payload["input_tokens"], payload["output_tokens"] ].all?(nil)

      model = find_model
      input_price = model.respond_to?(:price) ? model.price(:input) : model.input_price_per_million
      output_price = model.respond_to?(:price) ? model.price(:output) : model.output_price_per_million

      input_cost = payload["input_tokens"].to_f / 1_000_000.0 * input_price.to_f
      output_cost = payload["output_tokens"].to_f / 1_000_000.0 * output_price.to_f
      thinking_cost = payload["thinking_tokens"].to_f / 1_000_000.0 * output_price.to_f

      self.cost = input_cost + output_cost + thinking_cost
    rescue RubyLLM::ModelNotFoundError
      self.cost = 0.0
    end

    def find_model
      registry = RubyLLM.models
      # RubyLLM 2 accepts provider as a keyword; 1.x uses a positional argument.
      if registry.method(:find).parameters.include?([ :key, :provider ])
        registry.find(payload["model"], provider: payload["provider"])
      else
        registry.find(payload["model"], payload["provider"])
      end
    end
  end
end
