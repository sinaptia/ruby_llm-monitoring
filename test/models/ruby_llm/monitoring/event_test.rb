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

    test "sets cost to zero for local provider" do
      event = ruby_llm_monitoring_events(:ollama_recent)

      assert_equal 0.0, event.cost
    end

    test "sets cost to zero when tokens are nil" do
      event = ruby_llm_monitoring_events(:no_tokens)

      assert_equal 0.0, event.cost
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
