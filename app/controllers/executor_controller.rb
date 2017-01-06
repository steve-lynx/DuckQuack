# encoding: utf-8

include Java
import java.lang.System

require 'jrubyfx'
require 'yaml'
require 'fileutils'
require 'facets'

import javafx.scene.control.TextArea
import javafx.scene.canvas.Canvas
import javafx.scene.control.Alert
import javafx.scene.control.ButtonType
import javafx.scene.paint.Color
import javafx.scene.control.Button
import javafx.scene.control.TextField
import javafx.event.ActionEvent
import javafx.scene.control.Label

class RunningCode

  attr_reader :canvas
  attr_reader :container
  attr_reader :graphic_context
  attr_reader :output
  attr_reader :source_controller

  require 'running_code_helpers'
  include RunningCodeHelpers

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
    self.class.send(:define_method, :clear_output) { @output.text = '' }
    self.class.send(:define_method, :print) { |text| @output.text += text.to_s }
    self.class.send(:define_method, :println) { |text| @output.text += "#{text.to_s}\n" }
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
      message = %(MESSAGE:\n#{excp.message}\nBACKTRACE:\n#{excp.backtrace.join("\n")})
      r = Regexp.new(Regexp.escape(error_code_marker).to_s + ':(\d*):in')
      n = message.scan(r)[0][0].to_i - 1
      @source_controller.set_error_point(n)      
      @output.text += "\n#{message}"
    end
  end

end

class ExecutorController

  attr_reader :containers
  attr_reader :output
  attr_reader :canvas
  attr_reader :source_controller

  def initialize(containers, source_controller)
    @containers = containers
    @source_controller = source_controller
    find_output_areas
  end

  def stack_pane
    @containers[0]
  end

  def output_pane
    @containers[1]
  end

  def find_output_areas
    @canvas = stack_pane.getChildren.reduce { |m, child|
      child.is_a?(Canvas) ? child : nil
    }
    @canvas.widthProperty.bind(stack_pane.widthProperty)
    @canvas.heightProperty.bind(stack_pane.heightProperty)
    
    @output = output_pane.getChildren.reduce { |m, child|
      child.is_a?(TextArea) ? child : nil
    }
    @output.get_style_class.add("output-pane");
    @output.get_stylesheets.add('file://' + File.join(app.configs[:path][:config], 'output-pane.css'))
  end
  private :find_output_areas

  def run
    running_code = RunningCode.new(stack_pane, @source_controller, @canvas, @output)
    running_code.activate
  end
  
end
