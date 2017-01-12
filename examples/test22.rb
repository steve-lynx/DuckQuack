
pulisci

papera = Duck.new(@canvas)

papera.punto

papera.spessore_penna = 1

255.times.each {|n|
  papera.colore_penna = Color.rgb(n, 128, 255 - n)
  papera.avanti(50 + 1.5*n)
  papera.destra(-90 + n)
  papera.punto
}