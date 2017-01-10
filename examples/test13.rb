#-*- ruby -*-

#Browser semplice

reimposta

testo = nil

area = nuova_finestra('Pippo',
  fit_width: 800,
  fit_height: 600) 

web = nil
url = nil

bottone = nuovo_bottone("naviga", x: 4, y: 4, parent: area) { |evento| 
  web.load(url.text)
}

url = nuovo_campo_di_testo(x: bottone.width + 16, y: 4, fit_width: 500, parent: area)

web = nuovo_browser_web(
  "http://codingmonamour.org", 
  parent: area,
  y: bottone.height + 10,
  fit_width: 800,
  fit_height: 600 - (bottone.height + 10)
)