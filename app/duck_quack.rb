# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

################################################################################
# DuckQuack Initializations
################################################################################

include Java
import java.lang.System
require 'rubygems'
require 'pathname'
require 'yaml'

RUN_PATH = System.getProperty("user.dir")

ENV['APP_ENV'] ||= 'development'

IS_IN_JAR = Pathname.new(
  File.expand_path(
    File.join(
      File.dirname(__FILE__), ".."))).realpath.to_s == "classpath:/"

if IS_IN_JAR
  ENV['APP_ENV'] = 'production'
  PATH_ROOT = 'uri:classloader:/' #"classpath:" #
  PATH_APP = File.join(PATH_ROOT, 'app')
  PATH_LIB = File.join(PATH_ROOT, 'lib')
  PATH_LIB_EXT = File.join(RUN_PATH, 'lib')
  PATH_JARS = File.join(PATH_ROOT, 'jars')
  PATH_CONTROLLERS = File.join(PATH_ROOT, 'controllers')
  PATH_HELPERS = File.join(PATH_ROOT, 'helpers')

  PATH_GEMS_INT = PATH_ROOT + 'gems'
  PATH_GEMS_EXT = File.join(RUN_PATH, 'gems')

  PATH_FXML = File.join(RUN_PATH, 'fxml') #'./fxml'
  PATH_CONFIG = File.join(RUN_PATH, 'config')
  PATH_LOCALE = File.join(PATH_CONFIG, 'locale')
  PATH_EDITOR = File.join(PATH_CONFIG, 'editor')
  PATH_DB = File.join(RUN_PATH, 'db')
else
  PATH_ROOT = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), ".."))).realpath.to_s
  PATH_APP = File.join(PATH_ROOT, 'app')
  PATH_LIB = File.join(PATH_APP, 'lib')
  PATH_LIB_EXT = File.join(PATH_ROOT, 'lib')
  PATH_JARS = File.join(PATH_APP, 'jars')

  PATH_GEMS_INT = File.join(PATH_APP, "gems")
  PATH_GEMS_EXT = File.join(PATH_ROOT, "gems")

  PATH_FXML = File.join(PATH_ROOT, 'fxml')
  PATH_CONFIG = File.join(PATH_ROOT, 'config')
  PATH_LOCALE = File.join(PATH_ROOT, 'config', 'locale')
  PATH_EDITOR = File.join(PATH_ROOT, 'config', 'editor')
  PATH_CONTROLLERS =  File.join(PATH_APP, 'controllers')
  PATH_HELPERS = File.join(PATH_APP, 'helpers')
  PATH_DB = File.join(PATH_ROOT, 'db')
end

PATH_FXML_JIT_CACHE = File.join(RUN_PATH, '.cache')

gem_paths = Gem.path
gem_paths << PATH_GEMS_INT
gem_paths << PATH_GEMS_EXT

Gem.use_paths(PATH_GEMS_INT, gem_paths)

$LOAD_PATH << PATH_APP unless $LOAD_PATH.include?(PATH_APP)
$LOAD_PATH << PATH_JARS unless $LOAD_PATH.include?(PATH_JARS)
$LOAD_PATH << PATH_LIB unless $LOAD_PATH.include?(PATH_LIB)
$LOAD_PATH << PATH_CONTROLLERS unless $LOAD_PATH.include?(PATH_CONTROLLERS)
$LOAD_PATH << PATH_HELPERS unless $LOAD_PATH.include?(PATH_HELPERS)
$LOAD_PATH << PATH_GEMS_INT unless $LOAD_PATH.include?(PATH_GEMS_INT)
$LOAD_PATH << PATH_GEMS_EXT unless $LOAD_PATH.include?(PATH_GEMS_EXT)

Dir[File.join(PATH_JARS, '*.jar')].sort.each { |h|
  puts "LOADING JAVA JARFILES: #{h} "
  require(h)
}
Dir[File.join(PATH_LIB, '*.rb')].sort.each { |h|
  puts "LOADING RUBY EXTENSIONS: #{h} "
  require(h)
}

################################################################################

require 'jrubyfx'
require 'sequel'

class DuckQuackApp < JRubyFX::Application

  import javafx.stage.Screen
  import javafx.application.Platform

  include AppHelpers
  attr_reader :stage
  attr_accessor :main_pane

  class << self

    def locale(path, lang)
      locale = File.join(path, lang.to_s, "locale.yml")
      @@locale = File.exist?(locale) ? YAML.load_file(locale).deep_rekey { |k| k.to_sym } :
        {:key => 'value', :methods => [{ :name => '', :alias => '' }]}
    end

    def configs
      if defined?(@@configs).nil?
        c = (YAML.load_file(File.join(PATH_CONFIG, 'config.yml'))).deep_rekey { |k| k.to_sym }
        @@configs = {
          :title => 'DuckQuack',
          :width => 960,
          :height => 700,
          :size => 'window',
          :lang => 'en',
          :tab_chars => '  ',
          :language => 'ruby',
          :generate_methods_list => false,
          :database => 'duck_quack',
          :highlighting => { :async => false, :time => 300 },
          :path  => {
            :root => PATH_ROOT,
            :app => PATH_APP,
            :fxml => PATH_FXML,
            :lib => PATH_LIB,
            :lib_ext => PATH_LIB_EXT,
            :config => PATH_CONFIG,
            :locale => PATH_LOCALE,
            :editor => PATH_EDITOR,
            :controllers => PATH_CONTROLLERS,
            :helpers => PATH_HELPERS,
            :db => PATH_DB,
          }
        }.deep_merge(c)
        @@configs.deep_rekey! { |k| k.to_sym }
      end
      @@configs
    end

    def initialization
      [
        self.configs[:path][:lib],
        self.configs[:path][:lib_ext],
        self.configs[:path][:config],
        self.configs[:path][:app],
        self.configs[:path][:controllers],
        self.configs[:path][:helpers]
      ].each {|path|
        $LOAD_PATH << path unless $LOAD_PATH.include?(path)
      }
      fxml_root(self.configs[:path][:fxml]) #, 'uri:classloader:/')
      @@configs[:locale] = self.locale(@@configs[:path][:locale], @@configs[:lang])
      @@configs
    end
  end

  attr_reader :configs
  attr_reader :stage
  attr_reader :database

  def initialize
    super
    logger.info("DuckQuack - Initialization")
    @configs = DuckQuackApp.initialization
    set_app(self)
    Dir[File.join(self.configs[:path][:lib], '*.{rb,jar}')].sort.each { |h|
      puts "LOADING EXTERNAL LIBS: #{h} "
      require(h)
    }
    Dir[File.join(self.configs[:path][:controllers], '*.rb')].sort.each { |h|
      puts "LOADING CONTROLLERS: #{h} "
      require(h)
    }
    Dir[File.join(self.configs[:path][:lib_ext], '*.{rb,jar}')].sort.each { |h|
      puts "LOADING EXTERNAL LIBS/JAR: #{h} "
      require(h)
    }
  end

  def _substitutions
    @configs.fetch2([:locale, :substitutions], {})
  end

  def _opt(key, default = '')
    @configs.fetch2([:locale, key.to_sym], default)
  end

  def _t(key)
    _opt(key, key.to_s.gsub(/\W|_/, ' ').squeeze(' '))
  end

  def _t_methods
    _opt(:methods, {})
  end

  def _t_method(key)
    _t_methods.fetch2([key.to_sym], key)
  end

  def _database_disconnect
    logger.info("Disconnecting database...")
    @database.disconnect
    logger.info("Database disconnected.")
    @database.nil?
  end

  def _database_connect
    logger.info("Connecting database...")
    require 'jdbc/sqlite3'
    Jdbc::SQLite3.load_driver
    require 'java'
    java_import Java::OrgSqlite::JDBC
    path_db = app.configs[:path][:db]    
    @database =
      Sequel.connect(
      "jdbc:sqlite:///" + File.join(path_db, "#{app.configs.fetch2([:database], 'duck_quack')}.db"),
      :loggers => [logger])
    @database.pragma_set(:auto_vacuum, 1)
    @database.pragma_set(:secure_delete, true)
    @database.pragma_set(:case_sensitive_like, false)
    logger.info("Database connected.")
    @database
  end

  def start(stage)
    @stage = stage
    bounds = Screen.get_primary.get_visual_bounds
    size = case @configs.fetch2([:size], 'window')
           when 'window'
             [@configs.fetch2([:width], 800), @configs.fetch2([:height], 600)]
           when 'medium'
             [bounds.get_width / 2, bounds.get_height / 2]
           else
             [bounds.get_width - 20, bounds.get_height - 40]
           end
    with(stage,
      title: @configs.fetch2([:title], 'title'),
      width: size[0],
      height: size[1]
    ) do
      fxml DuckQuackController      
      show
    end
  end

  def stop
    ExecutorsPool.stop_all
  end

  def close
    ExecutorsPool.stop_all
    logger.info("DuckQuack - Closing")
    Platform.exit
  end

end

DuckQuackApp.launch
