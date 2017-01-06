#-*- ruby -*-

reimposta

 import javafx.scene.image.Image
 import javafx.scene.image.ImageView

  def control_add2(control)
    @container.get_children.add(control)
    @container.applyCss
    @container.layout
    bounds = control.get_bounds_in_parent
    control.width = bounds.get_width
    control.height = bounds.get_height
  end

   def image_view_create(image, opts = {})
    params = {
      :x => 0,
      :y => 0,
      :resize => {:width => 130, :height => 50, :preserve => true}
    }.deep_merge(opts)
    c = ImageView.new
    image = Image.new("file://" + image, true)
    c.setImage(image)
    if params[:resize]
      width, height = [params[:resize][:width], params[:resize][:heigth]]
      c.setFitWidth(width) unless width.nil?
      c.setFitHeight(height) unless height.nil?
      c.setPreserveRatio(!params[:resize][:preserve].nil?)
    end
    c.setSmooth(true);
    c.setCache(true);
    c.relocate(params[:x], params[:y])
    @container.get_children.add(c)
    @container.applyCss
    @container.layout
    c
  end

image_view_create("/home/nissl/Immagini/pixmaps/avatar.png", )