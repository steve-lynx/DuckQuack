# encoding: utf-8

include Java
import java.lang.System
require 'jrubyfx'
require 'yaml'
import javafx.stage.Screen
javafx.application.Platform

class DuckQuackApp < JRubyFX::Application
  include AppHelpers
  attr_reader :stage
  
  class << self

    def locale(path, lang)
      locale = File.join(path, lang.to_s, "locale.yml")
      @@locale = File.exist?(locale) ? YAML.load_file(locale).deep_rekey { |k| k.to_sym } :
        {:key => 'value', :methods => [{ :name => '', :alias => '' }]}
    end
    
    def configs
      if defined?(@@configs).nil?
        c = (YAML.load_file(File.join(File.join(PATH_ROOT, 'config'), 'config.yml'))).deep_rekey { |k| k.to_sym }
        @@configs = {
          :title => 'DuckQuack',
          :width => 960,
          :height => 700,
          :size => 'window',
          :lang => 'en',
          :tab_chars => '  ',
          :generate_methods_list => false,
          :database => {
            :active => false,
            :name => 'duck_quack'
          },
          :path  => {
            :root => PATH_ROOT,
            :app => PATH_APP,
            :fxml => File.join(PATH_ROOT,'app', 'fxml'),
            :lib => File.join(PATH_ROOT, 'lib'),
            :config => File.join(PATH_ROOT, 'config'),
            :locale => File.join(PATH_ROOT, 'config', 'locale'),
            :controllers => File.join(PATH_ROOT,'app', 'controllers'),
            :db => File.join(PATH_ROOT, 'db'),
          }
        }.deep_merge(c)
        @@configs.deep_rekey! { |k| k.to_sym }
      end
      @@configs
    end
    
    def initialization
      [  
        self.configs[:path][:lib], 
        self.configs[:path][:config],
        self.configs[:path][:app],
        self.configs[:path][:controllers]
      ].each {|path|
        $LOAD_PATH << path unless $LOAD_PATH.include?(path)
      }
      fxml_root(self.configs[:path][:fxml])
      @@configs[:locale] = self.locale(@@configs[:path][:locale], @@configs[:lang])
      @@configs
    end
  end

  attr_reader :configs

  def initialize
    super    
    logger.info("DuckQuack - Initialization")
    @configs = DuckQuackApp.initialization    
    set_app(self)
    Dir[File.join(self.configs[:path][:lib], '*.{rb,jar}')].sort.each { |h| p h; require(h) }
    Dir[File.join(self.configs[:path][:controllers], '*.rb')].sort.each { |h| require(h) }
    Dir[File.join(self.configs[:path][:db], '*.rb')].sort.each { |h| require(h) } if self.configs.fetch2([:database, :active], false)
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

  def close
    logger.info("DuckQuack - Closing")
    Platform.exit
  end
  
end

DuckQuackApp.launch

