module RubyLLM::Monitoring
  class AlertsController < ApplicationController
    def index
      @alert_rules = RubyLLM::Monitoring.alert_rules
    end
  end
end
