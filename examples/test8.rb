#-*- ruby -*-
reimposta

media = "download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"

visore = visore_multimediale(media, x: 10, y: 20, fit_height: 200, protocol: :http) 

bottone_play = nuovo_bottone( 
  "play", 
  x: 10, 
  y: visore.get_fit_height + 30) { |evento| visore.media_player.play }

bottone_stop = nuovo_bottone(
  "stop", 
  x: bottone_play.width, 
  y: visore.get_fit_height + 30) { |evento| visore.media_player.stop }


nome = File.join(cartella_di_lavoro, "images/Braccobaldo.png")
image_view_create(nome, x: 10, y: 260)