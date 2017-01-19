# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

include Java
import java.lang.System

class ExecutorsPool

  class << self

    @@executors = []

    def [](klass)
      ex = @@executors.find { |e|  e[:c] == klass }
      if ex.nil? 
        self.set({ :c => klass, :e => Executors.newSingleThreadExecutor, :t => 'SingleThreadExecutor'})
      else
        ex[:e]
      end
    end
    alias :get :[]

    def contains?(klass)
      !(@@executors.find { |e|  e[:c] == klass }).nil?
    end

    def set(executor)
      if contains?(executor[:e])
        get(executor[:e])
      else
        @@executors << executor
        executor[:e]
      end
    end

    def get_all
      @@executors
    end

    def stop(klass)
      e = self[klass]
      e.shutdown unless e.nil?
    end

    def stop_all
      unless @@executors.empty?
        @@executors.each { |e| e[:e].shutdown }
        @@executors = []
      end
    end
    
  end
  
end
