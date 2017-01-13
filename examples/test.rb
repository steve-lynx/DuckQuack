reset
setFill(Color.rgb(255,0,0))
setStroke(Color.rgb(0,255,0))
setLineWidth(5)
strokeLine(40, 10, 10, 40)
fillOval(10, 60, 30, 30)
strokeOval(60, 60, 30, 30)
fillRoundRect(110, 60, 30, 30, 10, 10)
strokeRoundRect(160, 60, 30, 30, 10, 10)

java_import javafx.scene.shape.ArcType

#fillArc(10, 110, 30, 30, 45, 240, ArcType::OPEN)
beginPath
arco(100, 110, 30, 30, 0, 360)
closePath
setFill(Color.rgb(255,0,255))
fill


pulisci

println "SCRIVO NELLA FINESTRA DI OUTPUT"

5.times.each do |numero|
  println "SCRIVO NELLA FINESTRA DI OUTPUT " + numero.to_s + " VOLTA"
end

definisco linea(startX, startY, endX, endY, n, colore)
  imposta_tratto(colore)
  imposta_larghezza_della_linea(n)
  traccia_linea(startX, startY, endX, endY)
fine

# commento 1
#222 commento su linea 222

=begin
commento multilinea
aaaaaa
aaaaaa
aaaaaa
=end

test = true

se test
	stampa("vero")
altrimenti
	stampa("falso")
fine

COSTANTE = 1

simbolo = :pippo

riempi_testo("SCRIVO NEL CANVAS", 200, 400)

linea(340, 100, 10, 300, 4, Color::GREEN)
linea(340, 100, 50, 300, 4, Color::RED)
linea(340, 100, 100, 300, 4, Color::YELLOW)
linea(340, 100, 150, 300, 4, Color::MAROON)
linea(340, 100, 200, 300, 4, Color::PURPLE)

def ovale(startX, startY, l, colore_tratto, colore)
  imposta_riempimento(colore)
  imposta_tratto(colore_tratto)
  imposta_larghezza_della_linea(l)
  riempi_ovale(startX, startY, 30, 30)
end

ovale(10, 60, 2, Color::RED, Color.rgb(0,255,0))

ovale(100, 60, 2, Color::YELLOW, Color.rgb(0,255,0))

riempi_ovale(60, 60, 30, 30)
riempi_rettangolo_arrotondato(110, 60, 30, 30, 10, 10)
riempi_rettangolo_arrotondato(160, 60, 30, 30, 10, 10)

riempi_arco(10, 110, 30, 30, 45, 240, ArcType::OPEN)

inizia_traiettoria
arco(100, 110, 30, 30, 0, 360)
chiudi_traiettoria
imposta_riempimento(Color.rgb(255,0,255))
riempi
