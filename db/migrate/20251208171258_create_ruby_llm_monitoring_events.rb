class CreateRubyLLMMonitoringEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :ruby_llm_monitoring_events do |t|
      t.integer :allocations
      t.float :cost
      t.float :cpu_time
      t.float :duration
      t.float :end
      t.float :gc_time
      t.float :idle_time
      t.string :name
      t.json :payload
      t.float :time
      t.string :transaction_id

      t.virtual :provider, type: :string, as: json_extract("provider"), stored: true
      t.virtual :model, type: :string, as: json_extract("model"), stored: true
      t.virtual :input_tokens, type: :integer, as: json_extract("input_tokens", as: :integer), stored: true
      t.virtual :output_tokens, type: :integer, as: json_extract("output_tokens", as: :integer), stored: true
      t.virtual :exception_class, type: :string, as: json_extract_array("exception", 0), stored: true
      t.virtual :exception_message, type: :string, as: json_extract_array("exception", 1), stored: true

      t.timestamps
    end
  end

  private

  def json_extract(field, as: nil)
    base_expr = case adapter_name.downcase
    when "mysql2"
      "JSON_UNQUOTE(JSON_EXTRACT(payload, '$.#{field}'))"
    else
      "payload->>'#{field}'"
    end

    return base_expr unless as == :integer

    case adapter_name.downcase
    when "mysql2"
      "CAST(JSON_UNQUOTE(JSON_EXTRACT(payload, '$.#{field}')) AS UNSIGNED)"
    when "postgresql"
      "(payload->>'#{field}')::integer"
    else
      "CAST(payload->>'#{field}' AS INTEGER)"
    end
  end

  def json_extract_array(field, index, as: nil)
    base_expr = case adapter_name.downcase
    when "mysql2"
      "JSON_UNQUOTE(JSON_EXTRACT(payload, '$.#{field}[#{index}]'))"
    when "postgresql"
      "(payload->'#{field}'->>#{index})"
    else
      "json_extract(payload, '$.#{field}[#{index}]')"
    end

    return base_expr unless as == :integer

    case adapter_name.downcase
    when "mysql2"
      "CAST(#{base_expr} AS UNSIGNED)"
    when "postgresql"
      "(#{base_expr})::integer"
    else
      "CAST(#{base_expr} AS INTEGER)"
    end
  end
end
