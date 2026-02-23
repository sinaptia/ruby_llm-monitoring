class AddThinkingTokensToRubyLLMMonitoringEvents < ActiveRecord::Migration[7.2]
  include RubyLLM::Monitoring::MigrationHelpers

  def change
    add_column :ruby_llm_monitoring_events, :thinking_tokens, :virtual, type: :integer, as: json_extract("thinking_tokens", as: :integer), stored: true
  end
end
