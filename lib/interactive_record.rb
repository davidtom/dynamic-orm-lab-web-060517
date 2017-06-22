
require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    query = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(query)
    table_info.map {|column| column["name"]}
  end

  def initialize(options={})
    # binding.pry
    options.each do |property, value|
      self.send(property.to_s + "=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names
  end

  def values_for_insert

  end

  def save

  end

  def self.find_by_name(name)

  end

  def self.find_by(x)

  end




end

InteractiveRecord.column_names
