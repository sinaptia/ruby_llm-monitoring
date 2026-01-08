require "test_helper"

module RubyLLM::Monitoring
  class AlertMailerTest < ActionMailer::TestCase
    test "alert_notification" do
      mail = AlertMailer.with(
        to: "team@example.com",
        subject: "Test Alert",
        body: "Something went wrong"
      ).alert_notification

      assert_equal "Test Alert", mail.subject
      assert_equal [ "team@example.com" ], mail.to
      assert_equal [ "from@example.com" ], mail.from
      assert_match "Something went wrong", mail.body.encoded
    end
  end
end
