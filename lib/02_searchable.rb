require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    where_line = params.map do |attr_name, val|
      "#{attr_name} = ?"
    end.join(" AND ")
    result = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
