DuckQuack
===

DuckQuack è un semplice ambiente per sperimentare in [Ruby](https://www.ruby-lang.org/it/).
È scritto in [JRuby](http://jruby.org/) per consentire una maggior portabilità grazie alla piattaforma Java su cui viene eseguito.
L'interfaccia usa le [JavaFx](http://docs.oracle.com/javase/8/javafx/api/toc.htm) come libreria di appoggio.

L'ambiente è diviso in tre parti: *il codice*, un *canvas* aperto su cui si può immediatamente disegnare, un'area di *output* testuale.

![immagine1](./images/img1.png)

### Avvio

Nella cartella ```bin``` ci sono due file: ```initialize``` ed ```jarify```. Il primo scarica JRuby *complete* ed installa le librerie Ruby necessarie (*gemme*) mentre il secondo serve per impacchettare l'applicazione in un unico file *jar* che comprende tutto quanto per funzionare: interprete, gemme e file della applicazione.
Il file *DuckQuack.jar* è generato nella radice del progetto.

Quindi la sequenza prima di partire è:

+ initialize
+ jarify

Dopodiché si può lanciare l'applicazione con ```java -jar DuckQuack.jar``` od usare l'eseguibile Windows(tm) ```DuckQuack.exe```.

### Codice

Il codice supportato è **Ruby** che viene eseguito e valutato tramite il pulsante *avvia*. In caso di errori:

![immagine2](./images/img2.png)

la linea viene evidenziata e il *backtrace* è presente nell'area di output.

Il sistema prevede una certa personalizzazione che va dalla colorazione della sintassi attraverso due file:

+ ```./config/editor/ruby/syntax-specs.yml```: *una serie di regole per il controllo della sintassi*
+ ```./config/editor/ruby/syntax-specs.css```: *una serie di stili per la colorazione della sintassi*

Nella stessa cartella un file ```code.yml``` permette di specificare una serie di righe predefinite da eseguire insieme al codice. Utile per eventuali *require* o *import* da usare in maniera predefinita.

Oltre alla personalizzazione del linguaggio e dell'editor tramite i file di cui sopra, nella cartella ```./config/locale/it``` c'è il file (```locale.yml```) per la traduzione di alcune parte dell'interfaccia, dei metodi da eseguire ed un *mapping* di sostituzioni in linea prima della esecuzione. In questo modo si dovrebbe poter personalizzare il codice per le varie eveniente senza troppa difficoltà.

Il sistema è espandibile im alcuni modi.

+ All'avvio vengono caricate le librerie java (jarfile) che sono presenti nella cartella ```./lib``` e vengono richiesti i file Ruby che ci sono. 
+ Nella cartella ```locale/it``` possono essere presenti file Ruby.
+ Gemme aggiuntive possono essere installate nella cartella ```./gems```

Per il *canvas* sono presenti tutte le primitive grafiche per disegnare e sono quindi immediatamente utilizzabili (fare riferimenti alla documentazione JavaFx della classe [GraphicsContext](http://docs.oracle.com/javase/8/javafx/api/javafx/scene/canvas/GraphicsContext.html).

Sono presenti alcune primitive per la creazione di interfacce grafiche all'interno del canvas e finestre esterne, nonché metodi utili:

+ ```reset``` (pulisce il camvas dagli oggetti di interfaccia)
+ ```alert(caption, message)``` e ```alert_and_wait(caption, message)``` (per finestre di allerta)
+ ```set_control_dimension(c, width, height)```
+ ```control_add(control)``` (aggiunge un controllo al contenitore dopo avero costruito)
+ ```button_create(text, opts, &action)``` (crea un controllo alle coordinate fornite)
+ ```label_create(text, opts = {}, &action)``` 
+ ```text_field_create(opts = {}, &action)```
+ ```canvas_create(opts = {})``` (inizializza un nuovo canvas)
+ ```text_area_create(opts = {})```
+ ```image_view_create(image, opts = {})```
+ ```audio_clip_create(source, opts = {})```
+ ```media_player_create(source, opts = {})```
+ ```window_create(caption, opts = {})```
+ ```web_engine_create(url = '', opts = {})``` (un browser web)
+ ```close_main_stage``` (chiudo o nasconde la finestra principale)
+ ```show_main_stage``` (mostra la finestra principale)
+ ... (fare riferimento al file ```app/helpers/running_code_helpers.rb```)

Ogni nome di funzione aggiunta nei vari modi è localizzabile nel suo nome con i meccanismi accennati prima.
Ovviamente tutto questo salvo bachi.

## Licenza

+ **Initial developer**: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
+ **Date**: 2016-12-18
+ **Company**: Pragmas <contact.info@pragmas.org>
+ **Licence**: Apache License Version 2.0, http://www.apache.org/licenses/
