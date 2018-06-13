require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key


      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key

      key_val = self.send(through_foreign_key)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
        #{source_table}
        ON
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
        SQL

        source_options.model_class.parse_all(results).first
    end
  end


  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_f_key = through_options.foreign_key
      through_p_key = through_options.primary_key

      source_table = source_options.table_name
      source_f_key = source_options.foreign_key
      source_p_key = source_options.primary_key

      id = self.send(through_f_key)
      results = DBConnection.execute(<<-SQL, id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_f_key} = #{source_table}.#{source_p_key}
        JOIN
          #{self.class.table_name}
        ON
          #{self.class.table_name}.id = #{through_table}.#{through_p_key}
        WHERE
          #{self.class.table_name}.#{through_p_key} = ?
      SQL

      source_options.model_class.parse_all(results)
    end
  end
end
