#-*- ruby -*-

reimposta

testo = nil

area = nuova_finestra('Pippo', :fit_width => 800, :fit_height => 600)
stampa area

bottone = nuovo_bottone("premi", parent: area, x: 10, y: 200) { |evento|
  allerta("testo del campo di input", testo.text)
}

sinistra = bottone.width + 16

etichetta = nuova_etichetta("testo", parent: area, x: sinistra, y: 180) 
testo = nuovo_campo_di_testo(parent: area, x: sinistra, y: 200)