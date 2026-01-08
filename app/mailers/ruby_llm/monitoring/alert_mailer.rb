module RubyLLM::Monitoring
  class AlertMailer < ApplicationMailer
    def alert_notification
      @body = params[:body]

      mail(
        to: params[:to],
        from: params[:from] || default_params[:from],
        subject: params[:subject]
      )
    end
  end
end
