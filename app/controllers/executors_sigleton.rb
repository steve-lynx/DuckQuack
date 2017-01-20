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

    @@fixed_pool = 5
    @@core_pool = 5
    @@executors = []

    def [](klass)
      ex = @@executors.find { |e|  e[:c] == klass }
      if ex.nil? 
        self.set({ :c => klass, :t => :single})
      else
        ex[:e]
      end
    end
    alias :get :[]

    def executor_new(t)
      case t
      when :single
        Executors.newSingleThreadExecutor
      when :cached
        Executors.newCachedThreadPool
      when :fixed
        Executors.newFixedThreadPool(fixed_pool)
      when :scheduled
        Executors.newScheduledThreadPool(core_pool)
      when :sinlge_scheduled
        Executors.newSingleThreadScheduledExecutor
      else
        Executors.newSingleThreadExecutor
      end 
    end
    private :executor_new

        def core_pool
      @@core_pool
    end
    
    def core_pool=(n)
      @@core_pool = n < 1 ? 1 : n
    end

    def fixed_pool
      @@fixed_pool
    end
    
    def fixed_pool=(n)
      @@fixed_pool = n < 1 ? 1 : n
    end 

    def contains?(klass)
      !(@@executors.find { |e|  e[:c] == klass }).nil?
    end

    def index(klass)
      (@@executors.find_index { |e|  e[:c] == klass })
    end

    def set(executor)
      if contains?(executor[:c])
        get(executor[:c])
      else
        executor[:e] = executor_new(executor[:t])
        @@executors << executor
        executor[:e]
      end
    end

    def all
      @@executors
    end

    def stop(klass)
      i = index(klass)
      if !i.nil?
        @@executors[i][:e].shutdownNow
        @@executors[i][:e] = executor_new(@@executors[i][:t])
      end      
    end

    def stop_all
      unless @@executors.empty?
        @@executors.each { |e| stop(e[:c]) }
      end
    end

    def shutdown_all
      unless @@executors.empty?
        @@executors.each { |e| e[:e].shutdownNow }
        @@executors = []
      end
    end
    
  end
  
end
