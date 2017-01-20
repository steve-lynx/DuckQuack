# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module UtilsHelpers
  
  def clear_output
    Platform.runLater(-> { @output.set_text('') })
  end
  
  def print(text)
    Platform.runLater(-> { @output.append_text(text.to_s) })
  end
  
  def println(text)
    Platform.runLater(-> { @output.append_text("#{text.to_s}\n") })
  end 
  
  def kill_term   
    Process.kill('TERM', Process.pid) 
  end

  def kill_int
    Process.kill("INT", Process.pid)
  end

  def enable_kills
    app.main_controller.instance_variable_get(:@kill_int_button).disable = false
    app.main_controller.instance_variable_get(:@kill_term_button).disable = false
  end

  def disable_kills
    app.main_controller.instance_variable_get(:@kill_int_button).disable = true
    app.main_controller.instance_variable_get(:@kill_term_button).disable = true
  end

end
