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
  papera.spessore_penna = 2
  papera.colore_penna = Color::RED
  4.times.each {|n| 
    #papera.alza_penna   
    papera.avanti(100)
    papera.destra
    papera.punto(size: 8)
  }
  papera.colore_fondo = Color::GREEN
  #papera.disegna_percorso
end

quadrato(tela)