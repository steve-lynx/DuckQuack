# encoding: utf-8

#for jruby-complete?
$LOAD_PATH.unshift PATH_ROOT
#
require 'sequel'

Sequel::Model.plugin(:schema)
Sequel::Model.plugin(:boolean_readers)
Sequel::Model.plugin(:validation_helpers)
Sequel::Model.raise_on_save_failure = false # Do not throw exceptions on failure

class Sequel::Model
  
  include AppHelpers
  
  def validate_date(date)
    unless values[date].blank?
      begin
        DateTime.parse(values[date]) if values[date].is_a?(String)
      rescue
        errors.add(date, I18n.t(:invalid_date))
      end
    end
  end
end

DB_NAME = app.configs.fetch2([:database, :name], 'duck_quack')

if RUBY_PLATFORM =~ /java/
  #jdbc-sqlite3 return string for timestamp fields
  class String
    def to_datetime
      begin
        DateTime.parse(self)
      rescue
        self
      end
    end

    def strftime(pattern)
      begin
        DateTime.parse(self).strftime(pattern)
      rescue
        self
      end
    end

    def day
      begin
        DateTime.parse(self).day
      rescue
        self
      end
    end

    def month
      begin
        DateTime.parse(self).month
      rescue
        self
      end
    end

    def year
      begin
        DateTime.parse(self).year
      rescue
        self
      end
    end
  end
end

def disconnect_database
  logger.info("Disconnecting database...")
  Sequel::Model.db.disconnect
  logger.info("Database disconnected.")
end

def connect_database
  logger.info("Connecting database...")
  if RUBY_PLATFORM =~ /java/
    require 'jdbc/sqlite3'
    Jdbc::SQLite3.load_driver
    require 'java'
    java_import Java::OrgSqlite::JDBC

    include AppHelpers
    path_db = app.configs[:path][:db]
    
    Sequel::Model.db = case APP_ENV
                       when :development then Sequel.connect("jdbc:sqlite:///" + File.join(path_db, "#{DB_NAME}_development.db"), :loggers => [logger])
                       when :production  then Sequel.connect("jdbc:sqlite:///" + File.join(path_db, "#{DB_NAME}_production.db"), :loggers => [logger])
                       when :test        then Sequel.connect("jdbc:sqlite:///" + File.join(path_db, "#{DB_NAME}_test.db"), :loggers => [logger])
                       end
  else
    require 'sqlite3'
    Sequel::Model.db = case APP_ENV
                       when :development then Sequel.connect("sqlite:///" + File.join(path_db, "#{DB_NAME}_development.db"), :loggers => [logger])
                       when :production  then Sequel.connect("sqlite:///" + File.join(path_db, "#{DB_NAME}_production.db"), :loggers => [logger])
                       when :test        then Sequel.connect("sqlite:///" + File.join(path_db, "#{DB_NAME}_test.db"), :loggers => [logger])
                       end
  end

  Sequel::Model.db.pragma_set(:auto_vacuum, 1)
  Sequel::Model.db.pragma_set(:secure_delete, true)
  Sequel::Model.db.pragma_set(:case_sensitive_like, false)
  logger.info("Database connected.")
end

connect_database
