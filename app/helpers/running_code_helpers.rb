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
      :padding => 12
    }.deep_merge(opts)
    @container.get_children.add(control)
    @container.applyCss
    @container.layout
    bounds = control.get_bounds_in_parent
    control.width = bounds.get_width + params[:padding]
    control.height = bounds.get_height + params[:padding]
  end

  def button_create(text, opts, &block)
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = Button.new(text)
    c.relocate(params[:x], params[:y])
    c.set_on_action(block) if block_given?
    control_add(c)
    c
  end

  def label_create(text, opts = {}, &action)
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = Label.new(text)
    c.relocate(params[:x], params[:y])
    c.set_on_action(action) if action
    control_add(c)
    c
  end

  def text_field_create(opts = {}, &action)
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = TextField.new
    c.relocate(params[:x], params[:y])
    c.set_on_action(action) if action
    control_add(c)
    c
  end
  
  def text_area_create(opts = {})
    params = {
      :x => 0,
      :y => 0
    }.deep_merge(opts)
    c = TextArea.new
    c.relocate(params[:x], params[:y])
    control_add(c)
    c
  end

  def image_view_create(image, opts = {})
    params = {
      :x => 0,
      :y => 0,
      :protocol => :file,      
      #:fit_width => 130, :fit_height => 150, :preserve => false,
      :smooth => true
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
    @container.get_children.add(c)
    @container.applyCss
    @container.layout
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
      :smooth => true
    }.deep_merge(opts)
    m = Media.new("#{params[:protocol].to_s}://" + source)
    mp = MediaPlayer.new(m)
    mv = MediaView.new(mp)
    w, h = [params[:fit_width], params[:fit_height]]
    mv.set_fit_width(w) unless w.nil?
    mv.set_fit_height(h) unless h.nil? 
    mv.set_smooth(params[:smooth])   
    mv.relocate(params[:x], params[:y])
    @container.get_children.add(mv)
    @container.applyCss
    @container.layout
    mp.set_auto_play(params[:autoplay])
    mv
  end
  
end
