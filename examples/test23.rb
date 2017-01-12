
pulisci

papera = Duck.new(canvas)

papera.punto

papera.spessore_penna = 1

4.times.each {|n|
  papera.colore_penna = Color::RED
  papera.avanti(100)
  papera.destra
  papera.punto
}