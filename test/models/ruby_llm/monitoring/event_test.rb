require "test_helper"

module RubyLLM::Monitoring
  class EventTest < ActiveSupport::TestCase
    test "calculates cost for cloud provider" do
      event = Event.create!(
        payload: {
          "provider" => "gemini",
          "model" => "gemini-2.5-flash",
          "input_tokens" => 1000,
          "output_tokens" => 500
        }
      )

      assert_not_nil event.cost
      assert event.cost > 0.0
    end

    test "calculates cost for cloud provider with thinking" do
      event = Event.create!(
        payload: {
          "provider" => "gemini",
          "model" => "gemini-2.5-flash",
          "input_tokens" => 1000,
          "output_tokens" => 500,
          "thinking_tokens" => 400
        }
      )

      assert_not_nil event.cost
      assert event.cost > 0.0
    end

    test "does not charge thinking twice when it is included in output" do
      event = Event.new(payload: {
        "provider" => "gemini",
        "model" => "gemini-2.5-flash",
        "input_tokens" => 1000,
        "output_tokens" => 500,
        "thinking_tokens" => 400
      })
      model = event.send(:find_model)
      input_price = model.respond_to?(:price) ? model.price(:input) : model.input_price_per_million
      output_price = model.respond_to?(:price) ? model.price(:output) : model.output_price_per_million

      event.save!

      assert_in_delta (1000 * input_price + 500 * output_price) / 1_000_000.0, event.cost, 1e-12
    end

    test "charges thinking separately when the model has a distinct reasoning price" do
      original = RubyLLM.models.find("gemini-2.5-flash")
      model = original.class.new(original.to_h.merge(pricing: {
        text_tokens: { standard: {
          input_per_million: 1, output_per_million: 2, reasoning_output_per_million: 3
        } }
      }))
      event = Event.new(payload: {
        "input_tokens" => 1000, "output_tokens" => 500, "thinking_tokens" => 400
      })
      event.define_singleton_method(:find_model) { model }

      event.save!

      assert_in_delta 0.0032, event.cost, 1e-12
    end

    test "sets cost to zero for an unknown model" do
      event = Event.create!(payload: {
        "model" => "nonexistent-monitoring-test-model",
        "input_tokens" => 1000,
        "output_tokens" => 500
      })

      assert_equal 0.0, event.cost
    end

    test "sets cost to zero for local provider" do
      event = ruby_llm_monitoring_events(:ollama_recent)

      assert_equal 0.0, event.cost
    end

    test "sets cost to zero when tokens are nil" do
      event = ruby_llm_monitoring_events(:no_tokens)

      assert_equal 0.0, event.cost
    end

    test "prefers the computed cost total for an unlisted model" do
      event = Event.create!(
        payload: {
          "provider" => "openrouter",
          "model" => "xiaomi/mimo-v2.6-flash",
          "tokens" => RubyLLM::Tokens.new(input: 337, output: 406, thinking: 284).to_h,
          "cost" => { "total" => 0.0002272536 }
        }
      )

      assert_equal 0.0002272536, event.cost
    end

    test "prices serialized nested tokens when the computed cost total is missing" do
      event = Event.create!(
        payload: {
          "provider" => "gemini",
          "model" => "gemini-2.5-flash",
          "tokens" => RubyLLM::Tokens.new(input: 1000, output: 500, thinking: 400).to_h,
          "cost" => { "total" => nil }
        }
      )
      model = event.send(:find_model)
      input_price = model.respond_to?(:price) ? model.price(:input) : model.input_price_per_million
      output_price = model.respond_to?(:price) ? model.price(:output) : model.output_price_per_million

      assert_in_delta (1000 * input_price + 500 * output_price) / 1_000_000.0, event.cost, 1e-12
    end

    test "accepts short token aliases with string or symbol keys" do
      [ { input: 1000, output: 500, thinking: 400 },
        { "input" => 1000, "output" => 500, "thinking" => 400 } ].each do |tokens|
        event = Event.create!(payload: {
          model: "gemini-2.5-flash", provider: "gemini", tokens: tokens
        })
        expected = RubyLLM::Cost.new(
          tokens: RubyLLM::Tokens.new(input: 1000, output: 500, thinking: 400),
          model: event.send(:find_model)
        ).total
        assert_in_delta expected, event.cost, 1e-12
      end
    end

    test "calculates cost with missing output_tokens in payload" do
      assert_nothing_raised do
        Event.create!(
          payload: {
            "model": "gemini-embedding-001",
            "embedding": {
              "model": "gemini-embedding-001",
              "vectors": [],
              "input_tokens": 11
            },
            "dimensions": 3072,
            "input_tokens": 11,
            "vector_count": 1
          }
        )
      end

      assert_not_equal 0.0, Event.last.cost
    end
  end
end
