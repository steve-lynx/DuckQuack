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
require 'ruby-beautify'
import org.fxmisc.richtext.CodeArea
import javafx.scene.control.Alert
import javafx.scene.control.ButtonType
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseEvent
import javafx.scene.input.KeyCode
import javafx.scene.control.ContextMenu
import javafx.scene.control.MenuItem
import javafx.scene.control.SeparatorMenuItem
import javafx.scene.input.MouseButton
import org.fxmisc.flowless.VirtualizedScrollPane

import java.io.PrintStream
import java.io.OutputStream

class ConsoleRedirect

  #class Out < java.io.OutputStream
  #  attr_accessor :text_area
  #  def write(i)
  #    Platform.runLater(-> { @text_area.append_text(i.chr) })
  #  end    
  #end

  class Out < StringIO    
    attr_accessor :text_area
    def write(text)
      Platform.runLater(-> { @text_area.append_text(text) })
    end  
  end

  class In < StringIO    
    attr_accessor :text_area
    def write(text)
      Platform.runLater(-> { @text_area.append_text(text) })
    end  
  end

  def initialize(text_area)
    out = Out.new
    out.text_area = text_area
    $stdout = out
    $stderr = out
  end

end

class Java::JavafxSceneCanvas::Canvas
  def isResizable
    true
  end

  def prefWidth(_height)
    getWidth
  end

  def prefHeight(_width)
    getHeight
  end

  def clear
    getGraphicsContext2D.clearRect(0, 0, getWidth, getHeight)
  end
end

class DuckQuackController
  include JRubyFX::Controller

  fxml 'main.fxml'

  include RubyBeautify

  attr_reader :main_pane

  def initialize
    ConsoleRedirect.new(@output)
    @code_editor.add_event_filter(KeyEvent::KEY_PRESSED) do |ev|
      if ev.get_code == KeyCode::TAB
        @code_editor.insert_text(@code_editor.get_caret_position, app.configs.fetch2([:tab_chars], '    '))
        ev.consume
      end
    end
    code_editor_context_menu
    scroll_pane = VirtualizedScrollPane.new(@code_editor)
    code_editor_info = Label.new('info:')
    code_editor_info.id = 'code_editor_info'
    @vbox_code_editor.add(scroll_pane)
    @vbox_code_editor.add(code_editor_info)
    VBox.setVgrow(scroll_pane, Priority::ALWAYS)
    @source_code_controller = SourceCodeController.new(@code_editor, code_editor_info)
    @executor = ExecutorController.new([@stack_pane, @output_pane], @source_code_controller)
    @filename = ''
    set_captions
  end

  def load_file_if_cli
    cli_load_file = app.configs.fetch2([:cli, :load], '')
    cli_run_file = app.configs.fetch2([:cli, :run], '')
    if cli_run_file.empty?
      load_file(File.realpath(cli_load_file)) if !cli_load_file.empty?
    else
      load_file(File.realpath(cli_run_file))
      run_clicked
    end
  end

  def code_editor_context_menu
    @context_menu = ContextMenu.new
    @context_menu.get_style_class.add('code-area-context-menu')
    undo_mi = MenuItem.new(app.t(:undo).capitalize)
    undo_mi.get_style_class.add('code-area-context-menu-item')
    undo_mi.set_on_action { |_ev| edit_undo_item_clicked }

    redo_mi = MenuItem.new(app.t(:redo).capitalize)
    redo_mi.get_style_class.add('code-area-context-menu-item')
    redo_mi.set_on_action { |_ev| edit_redo_item_clicked }

    cut_mi = MenuItem.new(app.t(:cut).capitalize)
    cut_mi.get_style_class.add('code-area-context-menu-item')
    cut_mi.set_on_action { |_ev| edit_cut_item_clicked }

    copy_mi = MenuItem.new(app.t(:copy).capitalize)
    copy_mi.get_style_class.add('code-area-context-menu-item')
    copy_mi.set_on_action { |_ev| edit_copy_item_clicked }

    paste_mi = MenuItem.new(app.t(:paste).capitalize)
    paste_mi.get_style_class.add('code-area-context-menu-item')
    paste_mi.set_on_action { |_ev| edit_paste_item_clicked }

    select_all_mi = MenuItem.new(app.t(:select_all).capitalize)
    select_all_mi.get_style_class.add('code-area-context-menu-item')
    select_all_mi.set_on_action { |_ev| edit_select_all_item_clicked }

    @context_menu.getItems.addAll(
      undo_mi,
      redo_mi,
      SeparatorMenuItem.new,
      cut_mi,
      copy_mi,
      paste_mi,
      SeparatorMenuItem.new,
      select_all_mi
    )

    @code_editor.add_event_filter(MouseEvent::MOUSE_CLICKED) do |ev|
      if ev.button == MouseButton::SECONDARY
        @context_menu.show(@code_editor, ev.get_screen_x, ev.get_screen_y)
        ev.consume
      end
    end
  end

  def set_captions
    @file_menu.text = app.t(:file).capitalize
    @file_new_menu_item.text = app.t(:new).capitalize
    @file_load_menu_item.text = app.t(:load).capitalize
    @file_save_menu_item.text = app.t(:save).capitalize
    @file_close_app_menu_item.text = app.t(:exit).capitalize

    @edit_undo_menu_item.text = app.t(:undo).capitalize
    @edit_redo_menu_item.text = app.t(:redo).capitalize
    @edit_cut_menu_item.text = app.t(:cut).capitalize
    @edit_copy_menu_item.text = app.t(:copy).capitalize
    @edit_paste_menu_item.text = app.t(:paste).capitalize
    @edit_select_all_menu_item.text = app.t(:select_all).capitalize
    @edit_format_menu_item.text = app.t(:format_code).capitalize

    @help_menu.text = app.t(:help).capitalize
    @help_about_menu_item.text = app.t(:about).capitalize

    @run_button.text = app.t(:run).capitalize
    @new_button.text = app.t(:new).capitalize
    @save_button.text = app.t(:save).capitalize
    @load_button.text = app.t(:load).capitalize
    @kill_int_button.text = app.t(:kill_int).capitalize
    @kill_term_button.text = app.t(:kill_term).capitalize
    @stop_tasks_button.text = app.t(:stop_tasks).capitalize
    @clear_output_button.text = app.t(:clear_output).capitalize
  end
  private :set_captions

  def write_output(message)
    Platform.runLater(-> { @output.append_text(message) })
  end

  def run_clicked
    @executor.run
  end

  def save_open_dialog(action = :open)
    java_import javafx.stage.FileChooser
    fileChooser = FileChooser.new
    file = case action
           when :open
             fileChooser.title = app.t(:load_file).capitalize
             fileChooser.show_open_dialog(app.stage)
           when :save
             fileChooser.title = app.t(:save_file).capitalize
             savefile = fileChooser.show_open_dialog(app.stage)
             if File.exist?(savefile.to_s)
               alert = Alert.new(Alert::AlertType::CONFIRMATION, app.t(:are_you_sure_to_overwrite).capitalize)
               alert.show_and_wait.filter { |response| response == ButtonType::CANCEL }.ifPresent { |_response| savefile = '' }
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
      app.set_title(@filename)
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
    if @executor.source_controller.empty?
      @filename = ''
      @executor.source_controller.code_set('')
    else
      alert = Alert.new(Alert::AlertType::CONFIRMATION, app.t(:are_you_sure_to_new).capitalize)
      alert.show_and_wait.filter do |response|
        response == ButtonType::OK
      end.ifPresent do |_response|
        @filename = ''
        @executor.source_controller.code_set('')
      end
    end
  end

  def load_clicked
    if @executor.source_controller.saved?
      load_file(save_open_dialog)
    else
      alert = Alert.new(Alert::AlertType::CONFIRMATION, app.t(:are_you_sure_to_load).capitalize)
      alert.show_and_wait.filter do |response|
        response == ButtonType::OK
      end.ifPresent do |_response|
        load_file(save_open_dialog)
      end
    end
  end

  def clear_output_clicked
    @output.set_text('')
  end

  def close_app_clicked
    app.close
  end

  def about_menu_item_clicked
    message = app.t(:about_text).capitalize
    alert = Alert.new(Alert::AlertType::INFORMATION, message)
    alert.header_text = app.t(:about_caption).capitalize
    alert.show
  end

  def edit_undo_item_clicked
    @code_editor.undo
  end

  def edit_redo_item_clicked
    @code_editor.redo
  end

  def edit_cut_item_clicked
    @code_editor.cut
  end

  def edit_copy_item_clicked
    @code_editor.copy
  end

  def edit_paste_item_clicked
    @code_editor.paste
  end

  def edit_select_all_item_clicked
    @code_editor.select_all
  end

  def edit_format_item_clicked
    code = pretty_string(
      @executor.source_controller.code_text_get,
      indent_token: ' ',
      indent_count: app.configs.fetch2([:tab_chars], '  ').size
    )
    @executor.source_controller.code_set(code)
  end

  def stop_tasks_clicked
    @executor.running_code.stop_tasks if @executor.running_code
  end

  def kill_term_clicked
    @executor.running_code.kill_term if @executor.running_code  
  end

  def kill_int_clicked
    @executor.running_code.kill_int if @executor.running_code  
  end
 
end
