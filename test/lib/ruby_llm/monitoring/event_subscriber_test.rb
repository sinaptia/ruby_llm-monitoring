require "test_helper"

module RubyLLM::Monitoring
  class EventSubscriberTest < ActiveSupport::TestCase
    test "creates event when chat is completed" do
      VCR.use_cassette "event_subscriber_test_creates_event_when_chat_is_completed" do
        chat = RubyLLM.chat provider: "ollama", model: "gemma3"

        assert_difference "Event.count", 1 do
          chat.ask "what's 1 + 1?"
        end
      end
    end

    test "creates event from notification event" do
      notification_event = ActiveSupport::Notifications::Event.new(
        "complete_chat.ruby_llm",
        Time.current,
        Time.current + 1.second,
        "transaction-123",
        { provider: "ollama", model: "gemma3", input_tokens: 100, output_tokens: 50 }
      )

      assert_difference "Event.count", 1 do
        EventSubscriber.new.call(notification_event)
      end

      event = Event.last
      assert_equal "complete_chat.ruby_llm", event.name
      assert_equal "transaction-123", event.transaction_id
      assert_equal "ollama", event.payload["provider"]
    end

    test "extracts exception from payload" do
      notification_event = ActiveSupport::Notifications::Event.new(
        "complete_chat.ruby_llm",
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
  end
end
