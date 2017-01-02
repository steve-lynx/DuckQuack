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

class RunningCode

  attr_reader :canvas
  attr_reader :container
  attr_reader :graphic_context
  attr_reader :output
  attr_reader :source_controller

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
    self.class.send(:define_method, :reset) {
      children = @container.get_children
      (children.reduce([]) { |acc, child| acc << child unless child.get_id == 'default_canvas'; acc}).each { |child| children.remove(child)}
    }
    self.class.send(:define_method, :alert) { |caption, message|
      alert = Alert.new(Alert::AlertType::INFORMATION, message)
      alert.header_text = caption
      alert.show
    }
    self.class.send(:define_method, :alert_and_wait) { |caption, message|
      alert = Alert.new(Alert::AlertType::INFORMATION, message, ButtonType::CANCEL, ButtonType::OK)
      alert.header_text = caption
      result = false
      alert.show_and_wait.filter { |response| response == ButtonType::OK }
      .if_present { |response| result = true}
      result
    }
    self.class.send(:define_method, :add_control) { |control| @container.get_children.add(control) }
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
        unless respond_to?(a)
          if method(m).arity == 0
            self.class.send(:define_method, a) { send(m) }
          else
            self.class.send(:define_method, a) { |*args| send(m, *args) }
          end
        end
      end
    }
  end
  private :inject_methods_alias

  def activate
    s = @source_controller.code_get
    begin
      self.instance_eval(s.to_s, "CODE", 0)
    rescue Exception => excp
      message = %(#{excp.message}\n#{excp.backtrace.join("\n")})
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
