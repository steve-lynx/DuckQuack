
pulisci
pulisci_output

@bounds = canvas.get_bounds_in_local

#p1 = PointRelative.new(0,0, @bounds)
#dot(p1.a_x, p1.a_y)
#stampa(p1.to_a)

#p2 = PointRelative.new(0, 30, @bounds)
#dot(p2.a_x, p2.a_y, 3, Color::GREEN)
#stampa(p2.to_a)

#r = p2.rotate(-90, 30, 0)

#stampa(r.to_a)

#dot(r.a_x, r.a_y, 3, Color::RED)

@p2 = PointRelative.new(0, 0, @bounds)

def x_after_distance(distance, angle)
  x = distance * Math.sin(angle * Math::PI / 180)
  @p2.a_x + x
end

def y_after_distance(distance, angle)  
  y = distance * Math.cos(angle * Math::PI / 180) 
  @p2.a_y - y
end

dot(@p2.a_x, @p2.a_y, 3)

x = x_after_distance(60, 90)
y = y_after_distance(60, 90)
dot(x, y, 3, Color::BROWN)

x = x_after_distance(60, -90)
y = y_after_distance(60, -90)
dot(x, y, 3, Color::RED)

x = x_after_distance(60, 180)
y = y_after_distance(60, 180)
dot(x, y, 5, Color::PURPLE)

x = x_after_distance(60, -180)
y = y_after_distance(60, -180)
dot(x, y, 3, Color::YELLOW)