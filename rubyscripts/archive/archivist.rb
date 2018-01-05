require 'pg'
require 'time'
require_relative 'data_god.rb'
require_relative 'psql_commands.rb'

class DatabaseManager
  attr_accessor :name, :database
  def initialize(db_name)
    self.name = db_name
    self.database = PG.connect(dbname: db_name, user: 'postgres')
  end
end

class Archivist < DatabaseManager
  # interacts with the current database by storing information through PG

  include InputCommands

  def store_all_mentions(array)
    array.each do |mention|
      if mention && mention[:currencies].length > 0
        # NOTE sometimes mention is empty apparently...
        self.archive_mention(mention)
      end
    end
  end

  def store_user(name)
    self.database.exec(self.record_user(name))
  end

  def store_source(name)
    self.database.exec(self.record_source(name))
  end

  def store_thread(title, comments, tag)
    self.database.exec(self.record_thread(title, comments, tag))
  end

  def store_currency(name)
    self.database.exec(self.record_currency(name))
  end

  def store_mention(source, thread, comment, user, currency, time)
    self.database.exec(self.record_mention(source, thread, comment, user, currency, time))
  end

  def archive_mention(object)
    self.store_source(object[:source])
    self.store_thread(object[:title],
      object[:tag],
      self.get_comments(object[:comments]))
    self.store_user(object[:user])

    object[:currencies].each do |currency|
      self.store_currency(currency)
      self.store_mention(
        object[:source],
        object[:title],
        false,
        object[:user],
        currency,
        self.format_time(object[:time])
      )
    end
  end

  def format_time(site_time)
    site_time.strftime("%Y-%m-%d %H:%M:%S +#{site_time.strftime("%z").to_i}")
  end

  def get_comments(string)
    if string == 'comment' || !string
       return 0
    end
    return string.gsub(/\scomments?/, '')
  end

  def delete_matches(table, column, value)
    if !column && !value
      self.database.exec("DELETE FROM #{table}")
    elsif column || value
      raise "wrong number of truthy arguments supplied to #{self}.delete_matches"
    else
      self.database.exec("DELETE FROM #{table} WHERE #{column}='#{value}'")
    end
  end

end
