class AddTagsToRubyLLMMonitoringEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :ruby_llm_monitoring_events, :tags, :json
  end
end
