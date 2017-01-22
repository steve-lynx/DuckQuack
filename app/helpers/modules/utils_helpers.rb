# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module UtilsHelpers

  
  ##
  #Clear output window.
  
  def clear_output
    Platform.runLater(-> { @output.set_text('') })
  end

  ##
  # Append text to output window.
  
  def print(text)
    Platform.runLater(-> { @output.append_text(text.to_s) })
  end

  ##
  # Append text to output window with carriage return.
  
  def println(text)
    Platform.runLater(-> { @output.append_text("#{text.to_s}\n") })
  end

  ##
  # Send the signal **TERM** to process. If not inferior process running close the application.
  
  def kill_term   
    Process.kill('TERM', Process.pid) 
  end

  ##
  # Send the signal **INT** to process. If not inferior process running close the application.
  
  def kill_int
    Process.kill("INT", Process.pid)
  end

  ##
  # Enable kills buttons, use with care. If not inferior process running close the application.

  def enable_kills
    app.main_controller.instance_variable_get(:@kill_int_button).disable = false
    app.main_controller.instance_variable_get(:@kill_term_button).disable = false
  end

  ##
  # Disable kills buttons,

  def disable_kills
    app.main_controller.instance_variable_get(:@kill_int_button).disable = true
    app.main_controller.instance_variable_get(:@kill_term_button).disable = true
  end

end
