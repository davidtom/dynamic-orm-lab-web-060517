
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
    #return all column names except the first (id)
    col_names = self.class.column_names.delete_if do |column|
      column == "id"
    end
    col_names.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.collect do |column_name|
      values << "'#{send(column_name)}'" unless send(column_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = '#{name}'"

    DB[:conn].execute(sql)
  end

  def self.find_by(x)

    insert_hash = {}
    x.each_with_object(insert_hash) do |data, hash|
      if data[1].class == Fixnum
        hash[data[0].to_s] = "#{data[1]}"
      else
        hash[data[0].to_s] = "'#{data[1]}'"
      end
    end

    where_array = insert_hash.map do |column, value|
      "#{column} = #{value}"
    end.join(" AND ")

    columns = x.keys
    values = x.values
    sql = "SELECT * FROM #{self.table_name} WHERE #{where_array}"
    
    DB[:conn].execute(sql)

  end




end

InteractiveRecord.column_names
