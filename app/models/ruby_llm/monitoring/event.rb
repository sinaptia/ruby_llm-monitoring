module RubyLLM::Monitoring
  class Event < ApplicationRecord
    include Alertable

    before_validation :set_cost

    private

    # Prefer the cost ruby_llm already computed — it honors provider-reported
    # pricing, which the local registry cannot price for unlisted models (e.g.
    # OpenRouter catalog entries). Otherwise price the token counts against the
    # registry. Falls back to zero when there is no usage at all.
    def set_cost
      self.cost = reported_cost || registry_cost || 0.0
    end

    def reported_cost
      cost = payload_value("cost")
      return nil unless cost.is_a?(Hash)

      total = cost["total"] || cost[:total]
      total.to_f if total
    end

    def registry_cost
      input = token_number("input_tokens")
      output = token_number("output_tokens")
      return nil if input.nil? && output.nil?

      model = RubyLLM::Models.find(payload_value("model"), payload_value("provider"))
      thinking = token_number("thinking_tokens").to_f

      input.to_f / 1_000_000.0 * model.input_price_per_million.to_f +
        output.to_f / 1_000_000.0 * model.output_price_per_million.to_f +
        thinking / 1_000_000.0 * model.output_price_per_million.to_f
    rescue RubyLLM::ModelNotFoundError
      nil
    end

    # Reads a token count from the flattened payload (ruby_llm <= 1.x and the
    # normalized EventSubscriber payload) or from the nested `tokens` object
    # (ruby_llm >= 2.x), accepting either the long (`input_tokens`) or short
    # (`input`) key.
    def token_number(name)
      direct = payload_value(name)
      return direct.to_f unless direct.nil?

      tokens = payload_value("tokens")
      return nil unless tokens.is_a?(Hash)

      short = name.to_s.delete_suffix("_tokens")
      value = tokens[name] || tokens[name.to_s] || tokens[short] || tokens[short.to_s]
      value.nil? ? nil : value.to_f
    end

    def payload_value(key)
      payload[key] || payload[key.to_s]
    end
  end
end
