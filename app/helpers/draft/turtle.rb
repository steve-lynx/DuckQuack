class Trtl
  VERSION = "0.0.2"

  CANVAS_WIDTH = 800
  CANVAS_HEIGHT = 600
  HOME_X = CANVAS_WIDTH / 2
  HOME_Y = CANVAS_HEIGHT / 2
  COLORS = %w{red blue green white cyan pink yellow}
  DEG = Math::PI / 180.0

  attr_accessor :heading, :x, :y
  attr_writer :color, :width
  attr_reader :canvas

  def initialize(canvas)
    @canvas = canvas
    @gc = canvas.get_graphics_context2_d   
    home
    draw
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

  def color(color)
    @color = color.to_s
  end

  def width(width)
    @width = width
  end
  
  def forward(amount = 20)
    new_x = (@x + dx * amount)
    new_y = (@y + dy * amount)
    move(new_x, new_y)
  end

  def back(amount = 20)
    new_x = (@x - dx * amount)
    new_y = (@y - dy * amount)
    move(new_x, new_y)
  end
  
  def move(new_x, new_y)
    if @drawing
    @gc.set_line_width(@width)
    @gc.set_stroke(@color)
    @gc.stroke_line(@x, @y, new_x, new_y)
    end
    @x, @y = new_x, new_y
    draw
  end
  
  def right(offset)
    @heading = (@heading + offset) % 360
    draw
  end
  
  def left(offset)
    @heading = (@heading - offset) % 360
    draw
  end

  def dot(size = nil)
    size ||= [@width + 4, @width * 2].max
    @gc.beginPath
    @gc.arc(@x - size / 2, @y - size / 2, @x + size / 2, @x + size / 2, 0, 360)
    @gc.closePath
    @gc.setFill(@color)
    @gc.fill
  end

  def position
    [@x, @y]
  end

  def home
    @x = HOME_X
    @y = HOME_Y
    @heading = 0
    draw
  end

  def ensure_drawn
    sleep 30
  end

  def wait
    ensure_drawn and gets
  end

  alias :run :instance_eval

  # Compatibility aliases (with turtle.py and KidsRuby primarily)
  alias :fd :forward
  alias :bk :back
  alias :rt :right
  alias :lt :left
  alias :pu :pen_up
  alias :pd :pen_down
  alias :penup :pen_up
  alias :pendown :pen_down
  alias :up :pen_up
  alias :down :pen_down
  alias :turnright :right
  alias :turnleft :left
  alias :backward :back
  alias :pencolor :color
  alias :goto :move
  alias :setpos :move
  alias :setposition :move
  alias :pos :position

  private
  def dx
    Math.cos(@heading * DEG)
  end
  
  def dy
    Math.sin(@heading * DEG)
  end

  def draw
    #canvas.delete(@turtle_line) if @turtle_line
    #@turtle_line = TkcLine.new(canvas, @x, @y, @x + dx * 5 , @y + dy * 5, :arrow => 'last', :width => 10, :fill => @color)
    # Can probably just use ensure_drawn actually..
    #TkTimer.new(60, 1) { Tk.update }.start.wait if @interactive
    true
  end
end

