require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = <<-SQL
    PRAGMA table_info('#{table_name}')
    SQL
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each{
      |row|
      column_names << row["name"]
    }
    column_names.compact
end

def initialize(options = {})
  options.each{
    |property, value|
    self.send("#{property}=", value)
  }
end

def save
  sql = "INSERT INTO #{table_name_for_insert} (#{column_names_for_insert}) VALUES (#{values_for_insert})"
  DB[:conn].execute(sql)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end

def table_name_for_insert
  names = []
  self.class.table_name
end

def values_for_insert
  values = []
  self.class.column_names.each {
    |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  }
  values.join(", ")
end


end
