
pulisci
pulisci_output

@bounds = canvas.get_bounds_in_local
@p = PointRelative.new(0, 0, @bounds)

draw_dot(@p.a_x, @p.a_y, 3)

direction = 0
distance = 100
size = 6
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::RED)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 45
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::BROWN)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 90
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::PURPLE)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 135
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::YELLOW)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 180
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::ORANGE)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 225
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::TEAL)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 270
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::BLUE)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)

direction = 315
p = @p.distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, size, Color::GOLD)
draw_line(@p.a_x, @p.a_y, p.a_x, p.a_y)