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
      self.cost = computed_cost_total || registry_cost || 0.0
    end

    def computed_cost_total
      cost = payload_value("cost")
      return nil unless cost.is_a?(Hash)

      total = cost["total"] || cost[:total]
      total.to_f if total
    end

    def registry_cost
      input = token_number("input_tokens")
      output = token_number("output_tokens")
      return nil if input.nil? && output.nil?

      tokens = RubyLLM::Tokens.new(
        input: input,
        output: output,
        thinking: token_number("thinking_tokens")
      )
      # RubyLLM handles models that include thinking in output as well as
      # models that price thinking separately, in both 1.16+ and 2.x.
      RubyLLM::Cost.new(tokens: tokens, model: find_model).total
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
      value = tokens[name.to_s] || tokens[name.to_sym] || tokens[short] || tokens[short.to_sym]
      value.nil? ? nil : value.to_f
    end

    def payload_value(key)
      payload[key.to_s] || payload[key.to_sym]
    end

    def find_model
      registry = RubyLLM.models
      # RubyLLM 2 accepts provider as a keyword; 1.x uses a positional argument.
      if registry.method(:find).parameters.include?([ :key, :provider ])
        registry.find(payload_value("model"), provider: payload_value("provider"))
      else
        registry.find(payload_value("model"), payload_value("provider"))
      end
    end
  end
end
