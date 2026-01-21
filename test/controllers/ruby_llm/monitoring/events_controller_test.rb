require "test_helper"

module RubyLLM::Monitoring
  class EventsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @event = ruby_llm_monitoring_events(:ollama_recent)
    end

    test "should get index" do
      get events_url
      assert_response :success
    end

    test "should show event" do
      get event_url(@event)
      assert_response :success
    end
  end
end
