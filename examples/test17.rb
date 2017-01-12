
pulisci

t = Turtle.new(canvas)

t.dot

t.pen_size = 1

255.times.each {|n|
  t.pen_color = Color.rgb(n, 128, 255 - n)
  t.forward(50 + 2*n)
  t.right(-90 + n)
  t.dot
}

