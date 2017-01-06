#-*- ruby -*-

reimposta

testo = nil

bottone = nuovo_bottone("premi", x: 10, y: 200) { |evento|
  allerta("testo del campo di input", testo.text)
}

sinistra = bottone.width + 16

etichetta = nuova_etichetta("testo", x: sinistra, y: 180) 
testo = nuovo_campo_di_testo(x: sinistra, y: 200)