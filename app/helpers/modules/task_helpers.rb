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

  ##
  # Stop current task for +millis+

  def sleep(millis)
    java.lang.Thread.sleep(millis)
  end

  ##
  # Force stop to all runnning tasks.

  def stop_tasks
    logger.info("STOP TASKS!")
    if @async_type != :sync
      ExecutorsPool.stop('TaskRunnableLater')
      ExecutorsPool.stop('TaskRunnable')
    else
      logger.info("RunningCode in sync mode")
    end
  end

  ##
  # Runnable Task with JavaFx Platform.runLater.

  class TaskRunnableLater < Java::javafx.concurrent.Task
    attr_accessor :proc
    def start
      ex = ExecutorsPool.set({ :c => 'TaskRunnableLater', :t => :cached })
      ex.execute(self)
    end
    def run
      #logger.debug("TASK LATER CALLING...")
      Platform.runLater(-> { @proc.call })
    end
  end

  ##
  # Runnable Task

  class TaskRunnable < Java::javafx.concurrent.Task
    attr_accessor :proc
    def start
      ex = ExecutorsPool.set({ :c => 'TaskRunnable', :t => :cached })
      ex.execute(self)
    end
    def call
      #logger.debug("TASK CALLING...")
      proc.call
    end
  end

  ##
  # Create a new Task with +block+ execution. Return a task.
  # Execute with +start+ method.

  def task(&block)      
    task = TaskRunnable.new
    task.proc = Proc.new(block)
    task
  end

  ##
  # Create a new Task with +block+ execution and +start+.

  def task_run(&block)  
    task(&block).start
  end

  ##
  # Create a new later Task with +block+ execution. Return a task.
  # Execute with +start+ method.

  def task_later(&block)      
    task = TaskRunnableLater.new
    task.proc = Proc.new(block)
    task
  end

  ##
  # Create a new later Task with +block+ execution and +start+.
  
  def task_run_later(&block)      
    task_later(&block).start
  end

  ##
  # Create a runLater Task with +block+ execution.

  def platform_run_later(&block)
    Platform.runLater(-> { Proc.new(block).call })
  end
  
end
