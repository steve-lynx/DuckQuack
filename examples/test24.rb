#-*- ruby -*-
pulisci
reimposta

testo = nil

area = nuova_finestra('Pippo',
  fit_width: 800,
  fit_height: 600) 

tela = nuova_tela( 
  parent: area, 
  background: Color::WHITE,
  x: 10, 
  y: 10, 
  fit_width: 780, 
  fit_height: 580)

def quadrato(canvas)
  papera = Duck.new(canvas)
  papera.punto
  papera.assi
  papera.spessore_penna = 1
  4.times.each {|n|
    papera.colore_penna = Color::RED
    papera.avanti(100)
    papera.destra
    papera.punto
  }
end

quadrato(tela)