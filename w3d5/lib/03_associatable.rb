require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.to_s.constantize
  end

  def table_name
    # ...
    @class_name.to_s.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions

  def initialize(name, options = {})
    # ...
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || name.to_s.capitalize
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ..
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || name.to_s.capitalize[0...-1]
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    define_method(name) do
      table_name = options.table_name
      foreign_key = self.send(options.foreign_key)
      options.model_class.where({options.primary_key => foreign_key}).first
    end
  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, self.to_s, options)
    self.assoc_options[name] = options
    define_method(name) do
      table_name = options.table_name
      primary_key = self.send(options.primary_key)
      options.model_class.where({options.foreign_key =>
      primary_key})
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
