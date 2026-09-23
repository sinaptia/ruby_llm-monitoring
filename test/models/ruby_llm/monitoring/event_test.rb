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

    test "calculates exact input output and thinking costs" do
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

      assert_in_delta (1000 * input_price + 900 * output_price) / 1_000_000.0, event.cost, 1e-12
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

    test "uses the nested cost total reported by ruby_llm 2.x" do
      event = Event.create!(
        payload: {
          "provider" => "openrouter",
          "model" => "xiaomi/mimo-v2.6-flash",
          "tokens" => { "input" => 337, "output" => 406, "thinking" => 284 },
          "cost" => { "total" => 0.0002272536 }
        }
      )

      assert_equal 0.0002272536, event.cost
    end

    test "prices nested ruby_llm 2.x tokens against the registry when no cost total is present" do
      event = Event.create!(
        payload: {
          "provider" => "gemini",
          "model" => "gemini-2.5-flash",
          "tokens" => { "input" => 1000, "output" => 500 }
        }
      )

      assert event.cost > 0.0
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
