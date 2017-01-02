# encoding: utf-8

include Java
import java.lang.System
require 'jrubyfx'
import org.fxmisc.richtext.CodeArea
import javafx.scene.control.Alert
import javafx.scene.control.ButtonType
import javafx.scene.input.KeyEvent
import javafx.scene.input.KeyCode

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

  def initialize
    @code_editor.add_event_filter(KeyEvent::KEY_PRESSED) { |ev|
      if ev.get_code == KeyCode::TAB
        @code_editor.insert_text(@code_editor.get_caret_position, app.configs.fetch2([:tab_chars], '    '))
        ev.consume
      end
      
    }
    scroll_pane = VirtualizedScrollPane.new(@code_editor)
    @vbox_code_editor.add(scroll_pane)
    VBox.setVgrow(scroll_pane, Priority::ALWAYS);
    @executor = ExecutorController.new([@stack_pane, @output_pane], SourceCodeController.new(@code_editor))
    @filename = ''
    set_captions
  end

  def set_captions
    @file_menu.text = app._t(:file).capitalize
    @file_new_menu_item.text = app._t(:new).capitalize
    @file_load_menu_item.text = app._t(:load).capitalize
    @file_save_menu_item.text = app._t(:save).capitalize
    @file_close_app_menu_item.text = app._t(:exit).capitalize
    
    @help_menu.text = app._t(:help).capitalize
    @help_about_menu_item.text = app._t(:about).capitalize
    
    @run_button.text = app._t(:run).capitalize
    @new_button.text = app._t(:new).capitalize
    @save_button.text = app._t(:save).capitalize
    @load_button.text = app._t(:load).capitalize
    @clear_output_button.text = app._t(:clear_output).capitalize
  end
  private :set_captions

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

  def close_app_clicked
    app.close
  end

  def about_menu_item_clicked
    message = app._t(:about_text).capitalize
    alert = Alert.new(Alert::AlertType::INFORMATION, message)
    alert.header_text = app._t(:about_caption).capitalize
    alert.show
  end
  
end
