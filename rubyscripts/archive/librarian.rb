require_relative 'data_god.rb'
require_relative 'psql_commands.rb'

class Librarian < DatabaseManager
  include SearchCommands

  attr_accessor :tables

  def initialize(db_name)
    super(db_name)
    self.tables = self.find_all_tables.values.flatten
  end

  def print_table(name)
    table = self.database.exec "SELECT * FROM #{name}"
    table.each do |row|
      puts row
    end
  end

  def find_all_tables
    self.database.exec self.all_tables
  end

  def table_specs(name)
    puts self.database.exec "\\d #{name}"
  end

  def record_table(name)
    self.tables.push(name)
  end

  def show_all_tables
    self.tables.each do |name|
      print "\r\n----------------------#{name}-----------------------\r\n"
      self.print_table(name)
    end
  end
end
