
reset

KEY = "8c957dd5fefc4e3624c2248f2aa737d9"

def che_tempo_fa(citta, codice_nazione, key)
  base = "http://api.openweathermap.org/data/2.5/weather"
  risposta = richiesta_http(
    url: base,
    params: {
      q: [citta, codice_nazione.upcase].join(','),
      units: 'metric',
      appid: KEY,
      lang: codice_nazione.lowercase
    }
  )
  JSON.parse(risposta.body)
end

risposta = che_tempo_fa('Roma', 'IT', KEY)

puts risposta

tempo = risposta["weather"][0]

immagine = "openweathermap.org/img/w/" + tempo["icon"] + ".png"
scrivi("ROMA", x: 10, y: 20)
mostra_immagine(immagine, x: 10, y: 20, protocol: :http)
scrivi(tempo["description"], x: 10, y: 74)