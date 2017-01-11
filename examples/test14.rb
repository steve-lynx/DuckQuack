#-*- ruby -*-

pulisci
pulisci_output

def axis(color = Color::BLACK, size = 1)
  bounds = getBoundsInLocal
  width = bounds.width.round
  height = bounds.height.round
  cbounds = { 
    width: width.to_i,
    height: height.to_i,
    x: (width / 2).to_i, 
    y: (height / 2).to_i }
  setLineWidth(size)
  setStroke(color)
  strokeLine(0, cbounds[:y], cbounds[:width], cbounds[:y])
  strokeLine(cbounds[:x], cbounds[:height], cbounds[:x], -cbounds[:height])
end

axis
