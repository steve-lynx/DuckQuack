# encoding: utf-8

include Java
import java.lang.System

require 'jrubyfx'
require 'yaml'
require 'fileutils'
require 'facets'

class ExecutorController

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
    #class_eval("include #{name.modulize}", m, 0)
  }

  def initialize(container, source_controller, output)
    @output = output
    @output.get_style_class.add("output-pane");
    @output.get_stylesheets.add('file://' + File.join(app.configs[:path][:config], 'output-pane.css'))
    @source_controller = source_controller
    @container = container
    find_canvas
    canvas_fix
    inject_gc_methods
    inject_canvas_methods
    inject_additional_methods
    generate_methods_list if app.configs.fetch2([:generate_methods_list], false)
    inject_methods_alias
  end

  def find_canvas
    @canvas = @container.getChildren.reduce { |m, child|
      child.is_a?(Java::JavafxSceneCanvas::Canvas) ? child : nil
    }
  end

  def canvas_fix
    @canvas.widthProperty.bind(@container.widthProperty)
    @canvas.heightProperty.bind(@container.heightProperty)
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

  def inject_additional_methods
    self.class.send(:define_method, :clear_output) { @output.text = '' }
    self.class.send(:define_method, :print) { |text| @output.text += text.to_s }
    self.class.send(:define_method, :println) { |text| @output.text += "#{text.to_s}\n" }
  end

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

  def run
    s = @source_controller.code_get
    begin
      self.instance_eval(s.to_s)
    rescue Exception => excp
      message = %(#{excp.message}\n#{excp.backtrace.join("\n")})
      @output.text += "\n#{message}"
    end
  end

  private(:find_canvas,
    :canvas_fix,
    :inject_gc_methods,
    :inject_canvas_methods,
    :inject_additional_methods,
    :generate_methods_list,
    :inject_methods_alias
  )

end
