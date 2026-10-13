require "test_helper"

module RubyLLM::Monitoring
  class EventSubscriberTest < ActiveSupport::TestCase
    test "creates event when chat is completed" do
      VCR.use_cassette "event_subscriber_test_creates_event_when_chat_is_completed" do
        chat = RubyLLM.chat provider: "ollama", model: "gemma3"

        before_count = Event.count
        chat.ask "what's 1 + 1?"
        assert_operator Event.count, :>, before_count

        assert Event.exists?(name: "chat.ruby_llm")
      end
    end

    test "creates event from notification event" do
      notification_event = ActiveSupport::Notifications::Event.new(
        "chat.ruby_llm",
        Time.current,
        Time.current + 1.second,
        "transaction-123",
        { provider: "ollama", model: "gemma3", input_tokens: 100, output_tokens: 50 }
      )

      assert_difference "Event.count", 1 do
        EventSubscriber.new.call(notification_event)
      end

      event = Event.last
      assert_equal "chat.ruby_llm", event.name
      assert_equal "transaction-123", event.transaction_id
      assert_equal "ollama", event.payload["provider"]
    end

    test "normalizes nested RubyLLM token and cost objects" do
      tokens = RubyLLM::Tokens.new(input: 100, output: 50, thinking: 10)
      cost = RubyLLM::Cost.new(tokens: tokens, model: RubyLLM.models.find("gemini-2.5-flash"))

      notification_event = ActiveSupport::Notifications::Event.new(
        "chat.ruby_llm",
        Time.current,
        Time.current + 1.second,
        "transaction-789",
        { provider: "gemini", model: "gemini-2.5-flash", tokens: tokens, cost: cost }
      )

      assert_difference "Event.count", 1 do
        EventSubscriber.new.call(notification_event)
      end

      event = Event.last
      assert_equal 100, event.payload["input_tokens"]
      assert_equal 50, event.payload["output_tokens"]
      assert_equal 10, event.payload["thinking_tokens"]
      assert_not_nil event.payload.dig("cost", "total")
      assert event.cost > 0.0
    end

    test "normalizes string keyed notifications and filters sensitive objects" do
      tokens = RubyLLM::Tokens.new(input: 100, output: 50, thinking: 10)
      cost = RubyLLM::Cost.new(tokens: tokens, model: RubyLLM.models.find("gemini-2.5-flash"))
      raw = {
        "provider" => "gemini", "model" => "gemini-2.5-flash",
        "tokens" => tokens, "cost" => cost, "chat" => Object.new
      }
      notification = ActiveSupport::Notifications::Event.new(
        "chat.ruby_llm", Time.current, Time.current + 1.second, "string-keys", raw
      )

      EventSubscriber.new.call(notification)

      event = Event.last
      assert_equal 100, event.input_tokens
      assert_equal 50, event.output_tokens
      assert_equal 10, event.payload["thinking_tokens"]
      assert_in_delta cost.total, event.cost, 1e-12
      assert_equal cost.total, event.payload.dig("cost", "total")
      assert_not event.payload.key?("chat")
      assert_same tokens, raw["tokens"]
    end

    test "normalizes short token aliases with symbol or string keys" do
      [ { input: 1000, output: 500, thinking: 400 },
        { "input" => 1000, "output" => 500, "thinking" => 400 } ].each do |tokens|
        notification = ActiveSupport::Notifications::Event.new(
          "chat.ruby_llm", Time.current, Time.current + 1.second, "aliases",
          { provider: "gemini", model: "gemini-2.5-flash", tokens: tokens }
        )

        EventSubscriber.new.call(notification)

        event = Event.last
        assert_equal 1000, event.input_tokens
        assert_equal 500, event.output_tokens
        assert_equal 400, event.payload["thinking_tokens"]
        expected = RubyLLM::Cost.new(
          tokens: RubyLLM::Tokens.new(input: 1000, output: 500, thinking: 400),
          model: event.send(:find_model)
        ).total
        assert_in_delta expected, event.cost, 1e-12
      end
    end

    test "extracts exception from payload" do
      notification_event = ActiveSupport::Notifications::Event.new(
        "chat.ruby_llm",
        Time.current,
        Time.current + 1.second,
        "transaction-456",
        { provider: "ollama", model: "gemma3", exception: [ "StandardError", "Something went wrong" ] }
      )

      assert_difference "Event.count", 1 do
        EventSubscriber.new.call(notification_event)
      end

      event = Event.last
      assert_equal "StandardError", event.exception_class
      assert_equal "Something went wrong", event.exception_message
    end

    test "handles payload with chat messages containing attachments" do
      VCR.use_cassette "event_subscriber_test_cleans_event_payload_when_chat_is_completed" do
        RubyLLM::Chat.new(model: "gemini-3-pro-image-preview").ask("Remove the purse from the model.", with: [ "https://app-cdn.osello.com/u/image_asset/oimg_1sEDBYq08L/upload/4d80ce71943f8ae131bf64605ad01f5e" ])

        event = Event.find_by!(name: "chat.ruby_llm")
        assert event.payload["chat"].blank?
        assert event.payload["input_messages"].blank?
        assert event.payload["messages_after"].blank?
      end
    end
  end
end
