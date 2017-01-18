# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

include Java
import java.lang.System

require 'jrubyfx'
import org.fxmisc.richtext.model.StyleSpans
import org.fxmisc.richtext.model.StyleSpansBuilder

import java.time.Duration
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javafx.concurrent.Task
import java.util.Optional

module TaskHelpers

  def sleep(millis)
    java.lang.Thread.sleep(millis)
  end

  class TaskRunnableLater
    include java.lang.Runnable
    attr_accessor :proc
    def start
      Executors.newSingleThreadExecutor.execute(self)
    end
    def run
      #logger.debug("RUNNABLE CALLING...")
      proc.call(@context, @container)
    end
  end

  class TaskRunnable < Java::javafx.concurrent.Task
    attr_accessor :proc
    def start
      Executors.newSingleThreadExecutor.execute(self)
    end
    def call
      #logger.debug("TASK CALLING...")
      proc.call
    end
  end

  def task(&block)      
    task = TaskRunnable.new
    task.proc = Proc.new(block)
    task
  end

  def task_run(&block)  
    task(&block).start
  end

  def task_later(&block)      
    task = TaskRunnableLater.new
    task.proc = Proc.new(block)
    task
  end
  
  def task_later_run(&block)      
    later(&block).start
  end
  
end
