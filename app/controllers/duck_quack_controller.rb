# encoding: utf-8

include Java
import java.lang.System
require 'jrubyfx'
import org.fxmisc.richtext.CodeArea
import javafx.scene.control.Alert
import javafx.scene.control.ButtonType

class Java::JavafxSceneCanvas::Canvas

  ##puts self.methods.sort

  def isResizable
    true
  end

  def prefWidth(height)
    getWidth
  end
  
  def prefHeight(width)
    getHeight
  end

  def clear
    getGraphicsContext2D.clearRect(0, 0, getWidth, getHeight)
  end

end

class DuckQuackController
  include JRubyFX::Controller
  fxml "main.fxml"

  attr_reader :source

  def initialize
    scroll_pane = VirtualizedScrollPane.new(@code_editor)
    @vbox_code_editor.add(scroll_pane)
    VBox.setVgrow(scroll_pane, Priority::ALWAYS);
    @executor = ExecutorController.new(@stack_pane, SourceCodeController.new(@code_editor), @output)
    @@filename = ''
  end

  def write_output(message)
    @output.text << message
  end
  
  def run_clicked
    @executor.run   
  end

  def save_open_dialog(action = :open)
    java_import javafx.stage.FileChooser
    fileChooser = FileChooser.new
    file = case action
            when :open
              fileChooser.title = app._t(:load_file).capitalize
              fileChooser.show_open_dialog(app.stage)
            when :save
              fileChooser.title = app._t(:save_file).capitalize
              savefile = fileChooser.show_open_dialog(app.stage)
              if File.exist?(savefile.to_s)
                alert = Alert.new(Alert::AlertType::CONFIRMATION, app._t(:are_you_sure_to_overwrite).capitalize + '?')
                alert.show_and_wait.filter { |response| response == ButtonType::CANCEL }.ifPresent { |response| savefile = '' }
                savefile
              else
                savefile
              end
            end
    file.to_s
  end

  def save_file(filename)
    unless filename.empty?
      @filename = filename
      File.open(@filename, 'w') { |f| f.write(@executor.source_controller.code_text_get) } 
    end
  end
  private :save_file

  def load_file(filename)
    unless filename.empty?
      @filename = filename
      File.open(@filename, 'r') { |f| @executor.source_controller.code_set(f.read) } 
    end
  end
  private :load_file  

  def save_clicked
    if File.exist?(@filename.to_s)
      save_file(@filename)
    else
      save_file(save_open_dialog(:save))
    end
  end

  def new_clicked
    @filename = ''
    @executor.source_controller.code_set('')
  end

  def load_clicked
    if @executor.source_controller.saved?
      load_file(save_open_dialog)
    else
      alert = Alert.new(Alert::AlertType::CONFIRMATION, app._t(:are_you_sure_to_load).capitalize + '?')
      alert.show_and_wait.filter { |response|
        response == ButtonType::OK
      }.ifPresent { |response|
        load_file(save_open_dialog)
      }
    end
  end

  def clear_output_clicked    
    @output.text = ''  
  end
end
