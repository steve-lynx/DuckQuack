#-*- ruby -*-

# Supporto per database sqlite

DB = app.database_connect 


DB.create_table!(:contatti) {
  String :nome
  String :cognome
  String :telefono
}

DB[:contatti].insert(
  nome: "Massimo", 
  cognome: "Ghisalberti", 
  telefono: "1234567890")
DB[:contatti].insert(
  nome: "Stefano", 
  cognome: "Penge", 
  telefono: "0000000000000")
DB[:contatti].insert(
  nome: "Anacleto", 
  cognome: "Mitraglia", 
  telefono: "0000000000000")

risultato = DB[:contatti].where(nome: "Massimo").first

stampa("il numero di telefono è: " + risultato[:telefono])
app.database_disconnect

