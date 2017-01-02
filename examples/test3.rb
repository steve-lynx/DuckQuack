
reimposta

bottone = Button.new("bottone")
bottone.layout_x = 10
bottone.layout_y = 200
bottone.width = 80

edit = TextField.new
edit.layout_x = bottone.get_width + 10
edit.layout_y = 200

bottone.set_on_action { |ev|
  alert("testo del campo di input", edit.text)
}

aggiungi_controllo(bottone)
aggiungi_controllo(edit)