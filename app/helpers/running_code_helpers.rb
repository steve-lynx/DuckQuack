# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module RunningCodeHelpers

  include Java
  import java.lang.System

  import javafx.event.ActionEvent
  import javafx.geometry.HPos
  import javafx.geometry.VPos
  import javafx.scene.Group
  import javafx.scene.Scene
  import javafx.scene.canvas.Canvas
  import javafx.scene.control.Alert
  import javafx.scene.control.Button
  import javafx.scene.control.ButtonType
  import javafx.scene.control.Label
  import javafx.scene.control.TextArea
  import javafx.scene.control.TextField
  import javafx.scene.control.Tooltip
  import javafx.scene.image.Image
  import javafx.scene.image.ImageView
  import javafx.scene.layout.AnchorPane
  import javafx.scene.layout.Pane
  import javafx.scene.media.AudioClip
  import javafx.scene.media.Media
  import javafx.scene.media.MediaPlayer
  import javafx.scene.media.MediaView
  import javafx.scene.paint.Color
  import javafx.scene.shape.ArcType
  import javafx.scene.shape.FillRule
  import javafx.scene.shape.StrokeLineCap
  import javafx.scene.shape.StrokeLineJoin
  import javafx.scene.text.Font
  import javafx.scene.text.FontSmoothingType
  import javafx.scene.text.TextAlignment
  import javafx.scene.web.WebView
  import javafx.stage.Screen
  import javafx.stage.Stage

  require 'fileutils'

  def pwd
    FileUtils.pwd
  end

  def reset
    children = @container.get_children
    (children.reduce([]) { |acc, child|
       acc << child unless child.get_id == 'default_canvas'; acc}
    ).each { |child| children.remove(child)}
    System.gc
  end

  def alert(caption, message)
    alert = Alert.new(Alert::AlertType::INFORMATION, message)
    alert.header_text = caption
    alert.show
  end

  def alert_and_wait(caption, message)
    alert = Alert.new(Alert::AlertType::INFORMATION, message, ButtonType::CANCEL, ButtonType::OK)
    alert.header_text = caption
    result = false
    alert.show_and_wait
    .filter { |response| response == ButtonType::OK }
    .if_present { |response| result = true}
    result
  end

  def set_control_dimension(c, width, height)
    unless c.nil? && width.nil? && height.nil?
      set_dim_width, set_dim_height =
        if c.respond_to?(:set_fit_width)
          [lambda { |w| c.set_fit_width(w) }, lambda { |h| c.set_fit_height(h) }]
        elsif c.respond_to?(:set_pref_width)
          [lambda { |w| c.set_pref_width(w) }, lambda { |h| c.set_pref_height(h) }]
        elsif c.respond_to?(:set_width)
          [lambda { |w| c.set_width(w) }, lambda { |h| c.set_height(h) }]
        elsif c.respond_to?(:set_min_width)
          [lambda { |w| c.set_min_width(w) }, lambda { |h| c.set_min_height(h) }]
        elsif c.respond_to?(:set_max_width)
          [lambda { |w| c.set_min_width(w) }, lambda { |h| c.set_min_height(h) }]
        else
          [lambda { |w| logger.warn("CONTROL WIDTH #{w} UNSUPPORTED")}, lambda { |h| logger.warn("CONTROL HEIGHT #{h} UNSUPPORTED")}]
        end
      set_dim_width.call(width)
      set_dim_height.call(height)
    end
  end

  def set_control_tooltip(c, text = '')
    c.set_tooltip(Tooltip.new(text))
  end

  def control_add(control, opts = {})
    params = {
      :parent => nil,
      :bounds => false
    }.deep_merge(opts)
    parent = params[:parent].nil? ? @container : params[:parent]
    parent.get_children.add(control)
    parent.applyCss
    parent.layout
    if params[:bounds]
      bounds = control.get_bounds_in_parent
      set_control_dimension(control, bounds.get_width, bounds.get_height)
    end
    parent
  end

  def button_create(text, opts = {}, &block)
    params = {
      :x => 0,
      :y => 0,
      :fit_width => 100,
      #:fit_height => 100,
      :parent => nil
    }.deep_merge(opts)
    c = Button.new(text)
    c.relocate(params[:x], params[:y])
    set_control_dimension(c, params[:fit_width], params[:fit_height]) 
    c.set_on_action(block) if block_given?
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end

  def canvas_create(opts = {})
    params = {
      :x => 0,
      :y => 0,
      :parent => nil,
      :fit_width => 200,
      :fit_height => 200,
      :background => Color::WHITE
    }.deep_merge(opts)
    c = Canvas.new(params[:fit_width], params[:fit_height])
    c.relocate(params[:x], params[:y])
    gc = c.get_graphics_context2_d
    gc.setFill(params[:background])
    gc.fillRect(0, 0, params[:fit_width], params[:fit_height])    
    gc.methods.each { |m|
      unless c.respond_to?(m)
        if gc.method(m).arity == 0
          c.class.send(:define_method, m) { get_graphics_context2_d.send(m) }
        else
          c.class.send(:define_method, m) { |*args| get_graphics_context2_d.send(m, *args) }
        end
      end
    }
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end

  def label_create(text, opts = {}, &action)
    params = {
      :x => 0,
      :y => 0,
      :fit_width => 100,
      #:fit_height => 100,
      :parent => nil
    }.deep_merge(opts)
    c = Label.new(text)
    c.relocate(params[:x], params[:y])
    set_control_dimension(c, params[:fit_width], params[:fit_height]) 
    c.set_on_action(action) if action
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end

  def text_field_create(opts = {}, &action)
    params = {
      :x => 0,
      :y => 0,
      :fit_width => 200,
      #:fit_height => 100,
      :parent => nil
    }.deep_merge(opts)
    c = TextField.new
    c.relocate(params[:x], params[:y])
    set_control_dimension(c, params[:fit_width], params[:fit_height]) 
    c.set_on_action(action) if action
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end
  
  def text_area_create(opts = {})
    params = {
      :x => 0,
      :y => 0,
      :fit_width => 200,
      :fit_height => 200,
      :parent => nil
    }.deep_merge(opts)
    c = TextArea.new
    c.relocate(params[:x], params[:y])
    set_control_dimension(c, params[:fit_width], params[:fit_height])
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end

  def image_view_create(image, opts = {})
    params = {
      :x => 0,
      :y => 0,
      :protocol => :file,      
      #:fit_width => 130, :fit_height => 150, :preserve => false,
      :smooth => true,
      :parent => nil
    }.deep_merge(opts)
    c = ImageView.new
    image = Image.new("#{params[:protocol].to_s}://" + image, true)
    c.setImage(image)
    set_control_dimension(c, params[:fit_width], params[:fit_height]) 
    c.set_preserve_ratio(!params[:preserve].nil?) unless params[:preserve].nil?
    c.set_smooth(params[:smooth])
    c.relocate(params[:x], params[:y])
    control_add(c, :parent => params[:parent], :bounds => false)
    c
  end

  def audio_clip_create(source, opts = {})
    params = {
      :protocol => :file,
      :autoplay => true,
      :volume => 1.0
    }.deep_merge(opts)
    a = AudioClip.new("#{params[:protocol].to_s}://" + source)
    a.set_volume(params[:volume])
    a.play
    a
  end

  def media_player_create(source, opts = {})
    params = {
      :x => 0,
      :y => 0,
      :protocol => :file,
      :autoplay => false,      
      #:fit_width => 100, :fit_height => 100,
      :smooth => true,
      :parent => nil
    }.deep_merge(opts)
    m = Media.new("#{params[:protocol].to_s}://" + source)
    mp = MediaPlayer.new(m)
    mv = MediaView.new(mp)
    set_control_dimension(mv, params[:fit_width], params[:fit_height]) 
    mv.set_smooth(params[:smooth])   
    mv.relocate(params[:x], params[:y])
    control_add(mv, :parent => params[:parent], :bounds => false)
    mp.set_auto_play(params[:autoplay])
    mv
  end

  def window_create(caption, opts = {})
    params = {
      :x => 0,
      :y => 0,   
      :fit_width => 200,
      :fit_height => 200,
      :background => Color::WHITE
    }.deep_merge(opts)

    root = Group.new
    stage = Stage.new
    stage.set_title(caption)
    stage.set_on_close_request { |event| app.stage.show }
    scene = Scene.new(root, params[:fit_width], params[:fit_height])
    pane = AnchorPane.new
    root.get_children.add(pane)
    stage.set_scene(scene)
    stage.size_to_scene    
    stage.show
    pane
  end

  def close_main_stage
    app.stage.hide
  end

  def show_main_stage
    app.stage.show
  end

  def web_engine_create(url = '', opts = {})
    params = {
      :x => 0,
      :y => 0,
      :fit_width => 400,
      :fit_height => 400,
      :parent => nil
    }.deep_merge(opts)
    c = WebView.new
    e = c.getEngine    
    c.relocate(params[:x], params[:y])
    w, h = [params[:fit_width], params[:fit_height]]
    c.set_pref_width(w) unless w.nil?
    c.set_pref_height(h) unless h.nil?
    e.load(url) unless url.empty?
    control_add(c, :parent => params[:parent], :bounds => true)
    e
  end

  def draw_axis(color = Color::BLACK, size = 1, canvas = @canvas)
    gc = canvas.get_graphics_context2_d
    bounds = canvas.get_bounds_in_local
    width = round_to_even(bounds.width)
    height = round_to_even(bounds.height)
    x0 = width / 2
    y0 = height / 2
    gc.set_line_width(size)
    gc.set_stroke(color)
    gc.stroke_line(0, y0, width, y0)
    gc.stroke_line(x0, height, x0, -height)
  end

  def round_to_even(n)
    x = n.to_i
    x % 2 == 0 ? x : x + 1
  end

  def translate_coord(x, y, canvas = @canvas)
    bounds = canvas.get_bounds_in_local
    width = round_to_even(bounds.width)
    height = round_to_even(bounds.height)
    x0 = width / 2
    y0 = height / 2
    [x0 + x, y0 + -y]
  end


  class Turtle

    attr_accessor :color
    attr_accessor :size
    attr_accessor :size

    def initialize(canvas = @canvas)
      @canvas = canvas
      @gc = @canvas.get_graphics_context2_d
      @x0, @y0 = translate_coord(0, 0)
      @color = Color::BLACK
      @size = 3
      home
      pen_down
    end

    def round_to_even(n)
      x = n.to_i
      x % 2 == 0 ? x : x + 1
    end

    def translate_coord(x, y)
      bounds = @canvas.get_bounds_in_local
      width = round_to_even(bounds.width)
      height = round_to_even(bounds.height)
      x0 = width / 2
      y0 = height / 2
      [x0 + x, y0 + -y]
    end

    def dx
      Math.cos(@heading * DEG)
    end
    
    def dy
      Math.sin(@heading * DEG)
    end

    def home
      @x = @x0
      @y = @y0
      @heading = 0
    end

    def pen_up
      @drawing = false
    end
    
    def pen_down
      @drawing = true
    end

    def is_drawing?
      @drawing
    end

    def dot(size = 4, color = Color::BLACK)
      if @drawing
        @gc.beginPath
        @gc.arc(@x, @y, size, size, 0, 360)
        @gc.closePath
        @gc.setFill(color)
        @gc.fill
      end
    end

    def heading(rad)
      @heading = rad
    end

    def move_to(x, y)
      @x, @y = translate_coord(x, y)
    end

    def position
      [@x, @y]
    end

    def right(offset)
      @heading = (@heading + offset) % 360
    end
    
    def left(offset)
      @heading = (@heading - offset) % 360
    end
    
  end
  
  
end
