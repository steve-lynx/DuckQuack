# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module DrawingHelpers

  class PointRelative

    RAD = Math::PI / 180
    
    attr_reader :a_x
    attr_reader :a_y
    attr_reader :r_x
    attr_reader :r_y
    attr_reader :bounds

    def initialize(r_x, r_y, bounds)
      @bounds = bounds
      @r_x = r_x.to_i
      @r_y = r_y.to_i
      translate
    end

    def radians(angle)
      angle * RAD
    end
    
    def round_to_even(n, floor = false)
      x = n.to_i
      x % 2 == 0 ? x : x + (floor ? -1 : +1)
    end
    private :round_to_even

    def translate
      x0 = round_to_even(@bounds.width) / 2
      y0 = round_to_even(@bounds.height) / 2
      @a_x = x0 + @r_x
      @a_y = y0 + -@r_y
    end
    private :translate

    def x_distance(angle, distance)
      x = distance * Math.sin(radians(angle))
      @r_x + x
    end
    private :x_distance

    def y_distance(angle, distance)  
      y = distance * Math.cos(radians(angle)) 
      @r_y - y
    end
    private :y_distance

    def distance(angle, d)
      self.class.new(
        x_distance(angle, d),
        y_distance(angle, d),
        @bounds
      )
    end

    def rotate(angle, x = 0, y = 0)
      x2 = @r_x - x
      y2 = @r_y - y
      cos = Math.cos(radians(angle))
      sin = Math.sin(radians(angle))      
      self.class.new(
        x2 * cos - y2 * sin + x, 
        x2 * sin + y2 * cos + y,
        @bounds
      )      
    end

    def to_a
      [@a_x, @a_y, @r_x, @r_y]
    end

    def absolute_x
      self.a_x
    end

    def absolute_y
      self.a_y
    end

    def relative_x
      self.r_x
    end

    def relative_y
      self.r_y
    end
    
  end

  def draw_axis(color = Color::BLACK, size = 1, canvas = @canvas)
    gc = canvas.get_graphics_context2_d
    bounds = canvas.get_bounds_in_local
    point = PointRelative.new(0, 0, bounds)   
    gc.set_line_width(size)
    gc.set_stroke(color)
    gc.stroke_line(0, point.a_y, point.bounds.width, point.a_y)
    gc.stroke_line(point.a_x, point.bounds.height, point.a_x, -point.bounds.height)
  end

  def round_to_even(n, floor = false)
    x = n.to_i
    x % 2 == 0 ? x : x + (floor ? -1 : +1)
  end

  def translate_coords(x, y, canvas = @canvas)
    bounds = canvas.get_bounds_in_local
    PointRelative.new(x, y, bounds)    
  end

  def draw_dot(x, y, size = 4, color = Color::BLACK, canvas = @canvas)
    gc = canvas.get_graphics_context2_d
    gc.beginPath
    gc.arc(x, y, size, size, 0, 360)
    gc.closePath
    gc.setFill(color)
    gc.fill
  end

  def draw_line(x0, y0, x1, y1, size = 2, color = Color::BLACK, canvas = @canvas)
    gc = canvas.get_graphics_context2_d
    gc.setStroke(color)
    gc.setLineWidth(size)
    gc.strokeLine(x0, y0, x1, y1)
  end

end
