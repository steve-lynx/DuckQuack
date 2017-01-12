
pulisci
pulisci_output

@bounds = canvas.get_bounds_in_local
@p = PointRelative.new(0, 0, @bounds)

draw_dot(@p.a_x, @p.a_y, 3)

direction = 0
distance = 100
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::RED)

direction = 45
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::BROWN)

direction = 90
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::PURPLE)

direction = 135
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::YELLOW)

direction = 180
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::ORANGE)

direction = 225
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::TEAL)

direction = 270
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::BLUE)

direction = 315
p = @p.after_distance(direction - 45, distance)
draw_dot(p.a_x, p.a_y, 3, Color::GOLD)