# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module RunningCodeHelpers

  import javafx.scene.paint.Color
  import javafx.scene.shape.ArcType
  import javafx.scene.text.Font
  import javafx.scene.text.TextAlignment
  import javafx.geometry.VPos
  import javafx.geometry.HPos
  import javafx.scene.text.FontSmoothingType
  import javafx.scene.shape.StrokeLineCap
  import javafx.scene.shape.StrokeLineJoin
  import javafx.scene.shape.FillRule
  import javafx.scene.image.Image
  import javafx.scene.image.ImageView
  import javafx.scene.media.AudioClip
  import javafx.scene.media.Media
  import javafx.scene.media.MediaView
  import javafx.scene.media.MediaPlayer
  import javafx.stage.Stage
  import javafx.stage.Screen
  import javafx.scene.Scene
  import javafx.scene.Group
  import javafx.scene.layout.Pane
  import javafx.scene.layout.AnchorPane
  import javafx.scene.canvas.Canvas

  require 'fileutils'

  def pwd
    FileUtils.pwd
  end

  def reset
    children = @container.get_children
    (children.reduce([]) { |acc, child|
       acc << child unless child.get_id == 'default_canvas'; acc}
    ).each { |child| children.remove(child)}
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

  def control_add(control, opts = {})
    params = {
      :padding => 12,
      :parent => nil,
      :bounds => false
    }.deep_merge(opts)
    parent = params[:parent].nil? ? @container : params[:parent]
    parent.get_children.add(control)
    parent.applyCss
    parent.layout
    if params[:bounds]
      bounds = control.get_bounds_in_parent
      control.width = bounds.get_width + params[:padding]
      control.height = bounds.get_height + params[:padding]
    end
    parent
  end

  def button_create(text, opts = {}, &block)
    params = {
      :x => 0,
      :y => 0,
      :parent => nil
    }.deep_merge(opts)
    c = Button.new(text)
    c.relocate(params[:x], params[:y])
    c.set_on_action(block) if block_given?
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end

  def canvas_create(opts = {})
    params = {
      :x => 0,
      :y => 0,
      :parent => nil,
      :fit_width => 100,
      :fit_height => 100,
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
      :parent => nil
    }.deep_merge(opts)
    c = Label.new(text)
    c.relocate(params[:x], params[:y])
    c.set_on_action(action) if action
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end

  def text_field_create(opts = {}, &action)
    params = {
      :x => 0,
      :y => 0,
      :parent => nil
    }.deep_merge(opts)
    c = TextField.new
    c.relocate(params[:x], params[:y])
    c.set_on_action(action) if action
    control_add(c, :parent => params[:parent], :bounds => true)
    c
  end
  
  def text_area_create(opts = {})
    params = {
      :x => 0,
      :y => 0,
      :parent => nil
    }.deep_merge(opts)
    c = TextArea.new
    c.relocate(params[:x], params[:y])
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
    width, height = [params[:fit_width], params[:fit_height]]
    c.set_fit_width(width) unless width.nil?
    c.set_fit_height(height) unless height.nil? 
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
    w, h = [params[:fit_width], params[:fit_height]]
    mv.set_fit_width(w) unless w.nil?
    mv.set_fit_height(h) unless h.nil? 
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
    scene = Scene.new(root, params[:fit_width], params[:fit_height])
    pane = AnchorPane.new
    root.get_children.add(pane)
    stage.set_scene(scene)
    stage.size_to_scene    
    stage.show
    pane
  end
  
end
