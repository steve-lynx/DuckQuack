#-*- ruby -*-

reimposta

testo = nil

area = nuova_finestra('Pippo',
  fit_width: 800,
  fit_height: 600) 

tela = nuova_tela( 
  parent: area, 
  background: Color::BLACK,
  x: 10, 
  y: 10, 
  fit_width: 780, 
  fit_height: 580)

tela.setFill(Color.rgb(255,0,0))
tela.setStroke(Color.rgb(0,255,0))
tela.setLineWidth(5)
tela.strokeLine(40, 10, 10, 40)
tela.fillOval(10, 60, 30, 30)
tela.strokeOval(60, 60, 30, 30)
tela.fillRoundRect(110, 60, 30, 30, 10, 10)
tela.strokeRoundRect(160, 60, 30, 30, 10, 10)