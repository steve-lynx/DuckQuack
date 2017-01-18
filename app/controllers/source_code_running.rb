# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

include Java
import java.lang.System

require 'jrubyfx'
import javafx.application.Platform
require 'yaml'
require 'fileutils'
require 'facets'

class RunningCode

  attr_reader :canvas
  attr_reader :container
  attr_reader :graphic_context
  attr_reader :output
  attr_reader :source_controller

  require 'code_running_helpers'
  include CodeRunningHelpers

  path = File.join(app.configs.fetch2([:path, :locale], './'), app.configs.fetch2([:lang], 'en'))
  $LOAD_PATH << path unless $LOAD_PATH.include?(path)
  Dir[File.join(path, '*.rb')].each { |m|
    require(m)
    name = File.basename(m).slice(0..-4)
    include const_get(name.modulize)
  }

  def initialize(container, source_controller, canvas, output)
    @output = output
    @source_controller = source_controller
    @container = container
    @canvas = canvas
    inject_gc_methods
    inject_canvas_methods
    inject_additional_methods
    generate_methods_list if app.configs.fetch2([:generate_methods_list], false)
    inject_methods_alias
  end

  def inject_canvas_methods
    @canvas.methods.sort.each { |m|
      unless respond_to?(m)
        if @canvas.method(m).arity == 0
          self.class.send(:define_method, m) { @canvas.send(m) }
        else
          self.class.send(:define_method, m) { |*args| @canvas.send(m, *args) }
        end
      end
    }
  end
  private :inject_canvas_methods

  def inject_gc_methods
    @graphic_context = @canvas.getGraphicsContext2D
    @graphic_context.methods.each { |m|
      unless respond_to?(m)
        if @graphic_context.method(m).arity == 0
          self.class.send(:define_method, m) { @graphic_context.send(m) }
        else
          self.class.send(:define_method, m) { |*args| @graphic_context.send(m, *args) }
        end
      end
    }
  end
  private :inject_gc_methods

  def inject_additional_methods
    #self.class.send(:define_method, :clear_output) { @output.text = '' }
    #self.class.send(:define_method, :print) { |text| @output.text += text.to_s }
    #self.class.send(:define_method, :println) { |text| @output.text += "#{text.to_s}\n" }

    self.class.send(:define_method, :clear_output) { 
      Platform.runLater(-> { @output.set_text('') })
    }
    self.class.send(:define_method, :print) { |text| 
      Platform.runLater(-> { @output.append_text(text.to_s) })
    }
    self.class.send(:define_method, :println) { |text| 
      Platform.runLater(-> { @output.append_text("#{text.to_s}\n") })
    }  
  end
  private :inject_additional_methods

  def generate_methods_list
    path = File.join(app.configs.fetch2([:path, :locale], './'), 'en')
    FileUtils.mkdir_p(path)
    locale = File.join(app.configs.fetch2([:path, :locale], './'), 'en', 'locale.yml')
    loc_hash = File.exist?(locale) ? YAML.load_file(locale).deep_rekey { |k| k.to_sym } :
      {:key => 'value', :methods => [{ :name => '', :alias => '' }]}
    h = methods.sort.reduce({}) { |acc, m| acc[m.to_s] = m.to_s; acc }
    File.open(locale, 'w') { |f|
      loc_hash[:en][:methods] = h
      loc_hash.deep_rekey! { |k| k.to_s }
      f.write(loc_hash.to_yaml)
    }
  end
  private :generate_methods_list

  def inject_methods_alias
    methods.sort.each { |m|
      a = app._t_method(m).to_sym
      if a.to_s != m.to_s
        logger.debug("ALIAS: #{a} for #{m}")
        self.class.send(:alias_method, a, m) unless respond_to?(a)
      end
    }
  end
  private :inject_methods_alias

  def activate
    error_code_marker = ">>>> #{app._t(:error_line_marker)} >>>> "
    s = @source_controller.code_get
    begin
      base = -s.fetch2([:preamble_size], 0) + 1
      self.instance_eval(s.fetch2([:code], ''), "\n#{error_code_marker}", base)
    rescue Exception => excp
      backtrace = excp.respond_to?(:backtrace_locations) ? excp.backtrace_locations.join("\n") : excp.backtrace.join("\n")
      message = %(MESSAGE:\n#{excp.message}\nBACKTRACE:\n#{backtrace})
      r = Regexp.new(Regexp.escape(error_code_marker).to_s + ':(?<linenumber>\d*)(?<cause>.*|:in)')
      match = message.match(r)
      @source_controller.syntax_highlighter.set_error_point(match['linenumber'].to_i - 1, match['cause'])
      @output.text += "\n#{message}"
    end
  end

  def clean_gc
    System.gc
  end

end
