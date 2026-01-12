module RubyLLM::Monitoring
  # Preview all emails at http://localhost:3000/rails/mailers/alert_mailer
  class AlertMailerPreview < ActionMailer::Preview
    # Preview this email at http://localhost:3000/rails/mailers/alert_mailer/alert_notification
    def alert_notification
      AlertMailer.with(
        to: "team@example.com",
        subject: "RubyLLM Monitoring Alert",
        body: "More than 10 errors in the last hour"
      ).alert_notification
    end
  end
end
