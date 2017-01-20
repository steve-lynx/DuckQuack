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

APP_VERSION="0.7.0.beta"

include Java
import java.lang.System
require 'rubygems'
require 'pathname'
require 'yaml'

RUN_PATH = System.getProperty("user.dir")

ENV['APP_ENV'] ||= 'development'
ENV['RACK_ENV'] ||= 'development'

IS_IN_JAR = Pathname.new(
  File.expand_path(
    File.join(
      File.dirname(__FILE__), ".."))).realpath.to_s == "classpath:/"

if IS_IN_JAR
  ENV['APP_ENV'] = 'production'
  ENV['RACK_ENV'] = 'production'
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
require 'optparse'
import javafx.stage.Screen
import javafx.application.Platform

class DuckQuackApp < JRubyFX::Application

  include AppHelpers

  def configs
    @@configs
  end

  def stage
    @@stage
  end

  def database
    @@database
  end

  def main_controller
    @@main_controller
  end

  def main_pane
    @@main_pane
  end

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
          :code_runner  => { :async => true, :type => :task }, #or :type => :later
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
      @@configs[:version] = APP_VERSION
      @@configs[:env] = ENV['APP_ENV'].to_sym
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

  def initialize
    super   
    logger.info("DuckQuack - Initialization")
    DuckQuackApp.initialization
    set_app(self)
    @@database = nil

    @translation_regexp = Regexp.new(%((?<inlinecode>#{Regexp.new('(?m)#{(\w+|.*)}')})))
    
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

  def substitutions
    configs.fetch2([:locale, :substitutions], {})
  end

  def opt(key, default = "")
    configs.fetch2([:locale, key.to_sym], default)
  end

  def build_ast(code, regex)
    matches = code.to_enum(:scan, regex).map { Regexp.last_match }
    matches.reduce([]) { |memo, matcher|
      names = matcher.names
      memo << names.size.times.reduce([]) { |acc, index|
        name =  names[index].to_sym
        acc = [name, matcher[name], matcher.begin(name), matcher.end(name)] unless matcher[name].nil?
        acc
      }      
      memo
    }
  end

  def t(key)
    t = opt(key, key.to_s.gsub(/\W|_/, ' ').squeeze(' '))
    build_ast(t, @translation_regexp).each { |a|
      code = a[1].match(Regexp.new('#{(\w+|.*)}'))
      value = eval(code[1]) rescue ''
      t.gsub!(a[1], value.to_s)
    }
    t
  end

  def t_methods
    opt(:methods, {})
  end

  def t_method(key)
    t_methods.fetch2([key.to_sym], key)
  end

  def database_disconnect
    logger.info("Disconnecting database...")
    database.disconnect
    logger.info("Database disconnected.")
    database.nil?
  end

  def database_connect
    logger.info("Connecting database...")
    require 'jdbc/sqlite3'
    Jdbc::SQLite3.load_driver
    require 'java'
    java_import Java::OrgSqlite::JDBC
    path_db = app.configs[:path][:db]    
    @@database =
      Sequel.connect(
      "jdbc:sqlite:///" + File.join(path_db, "#{app.configs.fetch2([:database], 'duck_quack')}.db"),
      :loggers => [logger])
    database.pragma_set(:auto_vacuum, 1)
    database.pragma_set(:secure_delete, true)
    database.pragma_set(:case_sensitive_like, false)
    logger.info("Database connected.")
    database
  end

  def init
    
    configs[:cli] = {
      :load => '',
      :run => '',
      :hide => false
    }
    OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.on("-v", "--version", "Show version") do |v|
        puts APP_VERSION
      end

      opts.on("-h", "--hide", TrueClass, "hide on run") do |f|
        configs[:cli][:hide] = true
      end

      opts.on("-l", "--load SOURCE", String, "load file") do |f|
        configs[:cli][:load] = f
      end

      opts.on("-r", "--run SOURCE", String, "run file") do |f|
        configs[:cli][:run] = f
      end
      
    end.parse!    
    configs[:cli][:hide] = false if !@@configs[:cli][:load].empty?
  end

  def set_title(title = '')
    t = configs.fetch2([:title], 'title') + " - #{APP_VERSION}" + (title.empty? ? '' : " - #{ title }")
    stage.set_title(t)
    t
  end

  def set_stage_size
    bounds = Screen.get_primary.get_visual_bounds
    case configs.fetch2([:size], 'window')
    when 'window'
      [configs.fetch2([:width], 800), configs.fetch2([:height], 600)]
    when 'medium'
      [bounds.get_width / 2, bounds.get_height / 2]
    else
      [bounds.get_width - 20, bounds.get_height - 40]
    end
  end
  private :set_stage_size

  def start(stage)
    @@stage = stage   
    size = set_stage_size
    with(stage, title: set_title, width: size[0], height: size[1]) {
      @@main_controller = fxml(DuckQuackController)
      @@main_pane = @@main_controller.main_pane
      show if !app.configs[:cli][:hide]    
      app.main_controller.load_file_if_cli
    }
  end

  def stop
    ExecutorsPool.shutdown_all
  end

  def close
    ExecutorsPool.shutdown_all
    logger.info("DuckQuack - Closing")
    Platform.exit
  end

end

DuckQuackApp.launch
