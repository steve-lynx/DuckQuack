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

    def initialize(canvas)
      @canvas = canvas
      @bounds = @canvas.get_bounds_in_local
      @gc = @canvas.get_graphics_context2_d
      @pen_color = COLOR
      @pen_size = PEN_SIZE
      @dot_color = COLOR
      @dot_size = DOT_SIZE
      home
      pen_down
    end

    def home
      @home_point = PointRelative.new(0, 0, @bounds)
      @current_point = PointRelative.new(0, 0, @bounds)
      @heading = HEADING
    end

    def pen_up
      @drawing = false
    end

    def pen_down
      @drawing = true
    end

    def pen_size(size = PEN_SIZE)      
      @pen_size = size
    end

    def pen_color(color = PEN_COLOR)      
      @pen_color = color
    end

    def dot_size(size = DOT_SIZE)      
      @dot_size = size
    end

    def dot_color(color = Color::BLACK)      
      @dot_color = color
    end

    def drawing?
      @drawing
    end

    def dot(size = @dot_size, color = @dot_color)
      draw_dot(@current_point.a_x, @current_point.a_y, size, color, @canvas) if @drawing
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
      @new_point = @current_point.distance(@heading, distance)      
      draw_line(@current_point.a_x, @current_point.a_y,
        @new_point.a_x, @new_point.a_y,@pen_size, @pen_color, @canvas) if drawing?
      @current_point = @new_point
    end

    def move_to(x = 0, y = 0)
      @current_point = PointRelative.new(x, y, @bounds)
    end

    def position
      [@current_point.r_x, @current_point.r_y]
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
        a = app._t_method(m).to_sym
        if a.to_s != m.to_s
          logger.debug("ALIAS: #{a} for #{m}")
          self.class.send(:alias_method, a, m) unless respond_to?(a)
        end
      }
    end

  end
  
end
