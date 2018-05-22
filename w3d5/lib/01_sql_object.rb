require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    # ...
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}

    SQL

    @columns = cols.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|
      define_method("#{col}") do
        attributes[col]
      end
      define_method("#{col}=") do |arg|
        attributes[col] = arg
      end
    end
  end

  def self.table_name=(table_name)
    # ...
  @table_name = table_name
  end

  def self.table_name
    # ...

    @table_name ||= self.name.tableize
  end

  def self.all
    # ...
    results = DBConnection.execute2(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    # debugger
    self.parse_all(results[1..-1])
  end

  def self.parse_all(results)
    # ...
    objs = []
    results.each do |result|
      objs << self.new(result)
    end
    objs
  end

  def self.find(id)
    # ...
    
  end

  def initialize(params = {})
    # ...
    params.each do |attr_name, v|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=", v)
    end
  end

  def attributes
    # ...
    @attributes ||= {}
  end

  def attribute_values
    # ...
    self.class.columns.map do |col|
      send("#{col}")
    end
  end

  def insert
    # ...
    col_names = self.class.columns.map(&:to_s).join(",")
    question_marks = (["?"] * self.class.columns.size).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # ...
    col_names = self.class.columns.map do |col|
      "#{col.to_s} = ?"
    end.join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    # ...
    unless self.id
      insert
    else
      update
    end
  end

end
