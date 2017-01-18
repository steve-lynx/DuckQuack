
reset

p1 = progress_bar_create(y: 10, progress: 0)
p2 = progress_bar_create(y: 40, progress: 0)

max = 100

esegui_compito { 
  (1..max).each { |n|
    p1.set_progress(n.to_f / max)
    stampa n
    aspetta(100)
  }

}

task_run{ 
  (1..max).each { |n|
    p2.set_progress(n.to_f / max)
    println n
    sleep(50)
  }

}