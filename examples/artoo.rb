require 'artoo/robot'

class HelloRobot < Artoo::Robot

  connection(:loop)
  name("Johnny")

  work do
    every(3.seconds) do
      puts "Hello. My name is #{name}."
    end

    after(10.seconds) do
      puts "Wow."
    end

  end
end

abilita_kill

esegui_compito do
  HelloRobot.work!(HelloRobot.new)
end
