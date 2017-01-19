# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module TurtleHelpers

  class Turtle

    include DrawingHelpers
    
    DEG = Math::PI / 180.0
    COLOR = Color::BLACK
    BACKGROUND = Color::WHITE
    PEN_SIZE = 2
    DOT_SIZE = 4
    HEADING = 180
    LENGTH = 100
    RECT = 90

    attr_accessor :pen_color
    attr_accessor :pen_size
    attr_accessor :dot_color
    attr_accessor :dot_size
    attr_accessor :heading
    attr_accessor :drawing
    attr_accessor :background
    attr_reader :path

    def initialize(canvas)
      @canvas = canvas
      @bounds = @canvas.get_bounds_in_local
      @gc = @canvas.get_graphics_context2_d
      @pen_color = COLOR
      @pen_size = PEN_SIZE
      @dot_color = COLOR
      @dot_size = DOT_SIZE
      @background = BACKGROUND
      home
      pen_down
    end

    def home
      @path = [PointRelative.new(0, 0, @bounds)]
      @heading = HEADING
    end

    def clear
      children = @canvas.get_parent.get_children
      (children.reduce([]) { |acc, child|       
         acc << child unless child == @canvas; acc}
      ).each { |child| children.remove(child)}
      @canvas.clear
      System.gc
    end

    def move_to_home
      move_to(0, 0)
    end

    def calculate_delta_position
      b0 = @canvas.get_bounds_in_parent
      b1 = @canvas.get_bounds_in_local
      [b0.max_x - b1.max_x, b0.max_y - b1.max_y]
    end
    private :calculate_delta_position

    def draw_path(opts = {})
      params = {
        :color => @pen_color,
        :background => @background,
        :size => @pen_size
      }.deep_merge(opts)
      d = calculate_delta_position
      p = Polyline.new
      p.get_points.add_all(
        @path.map { |point| [point.a_x.to_f + d[0], point.a_y.to_f + d[1]] }.flatten
      )
      p.setStroke(params[:color])
      p.setFill(params[:background])
      p.setStrokeWidth(params[:size])
      @canvas.get_parent.get_children.add(p)
    end

    def draw_path_polygon(opts = {})
      params = {
        :color => @pen_color,
        :background => @background,
        :size => @pen_size
      }.deep_merge(opts)
      d = calculate_delta_position
      p = Polygon.new
      p.get_points.add_all(
        @path.map { |point| [point.a_x.to_f + d[0], point.a_y.to_f + d[1]] }.flatten
      )
      p.setStroke(params[:color])
      p.setFill(params[:background])
      p.setStrokeWidth(params[:size])
      @canvas.get_parent.get_children.add(p)
    end

    def pen_up
      @drawing = false
    end

    def pen_down
      @drawing = true
    end

    def pen_size(size = PEN_SIZE)      
      @pen_size = size
      @gc.setLineWidth(@pen_size)
    end

    def pen_color(color = PEN_COLOR)      
      @pen_color = color
      @gc.setStroke(@pen_color)
    end

    def dot_size(size = DOT_SIZE)      
      @dot_size = size
    end

    def dot_color(color = Color::BLACK)      
      @dot_color = color
    end

    def background(color = BACKGROUND)
      @background = color
      @gc.setFill(@background)
    end    

    def drawing?
      @drawing
    end

    def dot(opts = {})
      params = {
        :color => @dot_color,
        :size => @pen_size
      }.deep_merge(opts)
      draw_dot(@path.last.a_x, @path.last.a_y, params[:size], params[:color], @canvas) if @drawing
    end

    def heading(angle = HEADING)
      @heading = angle % 360
    end

    def forward(distance = LENGTH)
      move(distance)
    end

    def back(distance = LENGTH)
      move(-distance)
    end

    def move(distance = LENGTH)
      @new_point = @path.last.distance(@heading, distance)
      draw_line(@path.last.a_x, @path.last.a_y,
        @new_point.a_x, @new_point.a_y, @pen_size, @pen_color, @canvas) if drawing?
      @path << @new_point
    end

    def move_to(x = 0, y = 0)
      @path << PointRelative.new(x, y, @bounds)
    end

    def position
      last = @path.last
      [last.r_x, last.r_y]
    end

    def right(angle = RECT)
      @heading = (@heading - angle) % 360
    end

    def left(angle = RECT)
      @heading = (@heading + angle) % 360
    end

    def axis(color = COLOR, size = 1)
      draw_axis(color, size, @canvas)
    end

  end

  class Duck < Turtle

    def initialize(canvas)
      super(canvas)
      methods.sort.each { |m|
        a = app.t_method(m).to_sym
        if a.to_s != m.to_s
          logger.debug("ALIAS: #{a} for #{m}")
          self.class.send(:alias_method, a, m) unless respond_to?(a)
        end
      }
    end

  end
  
end
