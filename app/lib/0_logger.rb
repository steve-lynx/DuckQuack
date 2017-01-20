# encoding: utf-8

require 'logger'

module Logging

  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  @loggers = {}

  class << self
    def logger_level
      case ENV['APP_ENV']
      when 'fatal'
        Logger::FATAL
      when 'error'
        Logger::ERROR
      when 'warn'
        Logger::WARN
      when 'info', 'production'
        Logger::INFO
      when 'debug', 'development'
        Logger::DEBUG
      else
        Logger::UNKNOWN
      end
    end
    
    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logger = if ENV['APP_ENV'] == 'development'
                 Logger.new($stdout)
               else
                 Logger.new(File.join(RUN_PATH, 'log', 'duckquack.log'))
               end
      logger.level = logger_level
      logger.progname = classname
      logger
    end
  end
end
