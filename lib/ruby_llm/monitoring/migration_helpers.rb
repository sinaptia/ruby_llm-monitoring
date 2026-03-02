module RubyLLM
  module Monitoring
    module MigrationHelpers
      def json_extract(field, as: nil)
        base_expr = case adapter_name.downcase
        when "mysql2", "trilogy"
          "JSON_UNQUOTE(JSON_EXTRACT(payload, '$.#{field}'))"
        else
          "payload->>'#{field}'"
        end

        return base_expr unless as == :integer

        case adapter_name.downcase
        when "mysql2", "trilogy"
          "CAST(JSON_UNQUOTE(JSON_EXTRACT(payload, '$.#{field}')) AS UNSIGNED)"
        when "postgresql"
          "(payload->>'#{field}')::integer"
        else
          "CAST(payload->>'#{field}' AS INTEGER)"
        end
      end

      def json_extract_array(field, index, as: nil)
        base_expr = case adapter_name.downcase
        when "mysql2", "trilogy"
          "JSON_UNQUOTE(JSON_EXTRACT(payload, '$.#{field}[#{index}]'))"
        when "postgresql"
          "(payload->'#{field}'->>#{index})"
        else
          "json_extract(payload, '$.#{field}[#{index}]')"
        end

        return base_expr unless as == :integer

        case adapter_name.downcase
        when "mysql2", "trilogy"
          "CAST(#{base_expr} AS UNSIGNED)"
        when "postgresql"
          "(#{base_expr})::integer"
        else
          "CAST(#{base_expr} AS INTEGER)"
        end
      end
    end
  end
end
