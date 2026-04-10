module RubyLLM
  module Monitoring
    module TimeGrouping
      extend ActiveSupport::Concern

      class_methods do
        def group_by_minute(column, range:, n: 1)
          interval = n * 60
          quoted = connection.quote_column_name(column)
          bucket_expr = time_bucket_expression(quoted, interval)

          where(column => range).group(Arel.sql(bucket_expr))
        end

        private

        def time_bucket_expression(column, interval)
          case connection.adapter_name
          when "PostgreSQL", "PostGIS", "Redshift"
            "FLOOR(EXTRACT(EPOCH FROM #{column}) / #{interval}) * #{interval}"
          when "Mysql2", "Mysql2Spatial", "Mysql2Rgeo", "Trilogy"
            "FLOOR(UNIX_TIMESTAMP(#{column}) / #{interval}) * #{interval}"
          when "SQLite"
            "(strftime('%s', #{column}) / #{interval}) * #{interval}"
          else
            raise "Unsupported adapter: #{connection.adapter_name}"
          end
        end
      end
    end
  end
end
