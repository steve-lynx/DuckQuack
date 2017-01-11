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

require 'ruby-beautify'

class Java::JavafxSceneCanvas::Canvas

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

  include RubyBeautify

  def initialize
    app.main_pane = @main_pane
    @code_editor.add_event_filter(KeyEvent::KEY_PRESSED) { |ev|
      if ev.get_code == KeyCode::TAB
        @code_editor.insert_text(@code_editor.get_caret_position, app.configs.fetch2([:tab_chars], '    '))
        ev.consume
      end
    }
    code_editor_context_menu
    scroll_pane = VirtualizedScrollPane.new(@code_editor)
    code_editor_info = Label.new("info:")
    code_editor_info.id = "code_editor_info"
    @vbox_code_editor.add(scroll_pane)
    @vbox_code_editor.add(code_editor_info)
    VBox.setVgrow(scroll_pane, Priority::ALWAYS);
    @source_code_controller = SourceCodeController.new(@code_editor, code_editor_info)
    @executor = ExecutorController.new([@stack_pane, @output_pane], @source_code_controller)
    @filename = ''
    set_captions
  end

  def code_editor_context_menu
    @context_menu = ContextMenu.new
    @context_menu.get_style_class.add("code-area-context-menu")
    undo_mi = MenuItem.new(app._t(:undo).capitalize)
    undo_mi.get_style_class.add("code-area-context-menu-item")
    undo_mi.set_on_action {  |ev| edit_undo_item_clicked }

    redo_mi = MenuItem.new(app._t(:redo).capitalize)
    redo_mi.get_style_class.add("code-area-context-menu-item")
    redo_mi.set_on_action {  |ev| edit_redo_item_clicked }

    cut_mi = MenuItem.new(app._t(:cut).capitalize)
    cut_mi.get_style_class.add("code-area-context-menu-item")
    cut_mi.set_on_action{ |ev| edit_cut_item_clicked }

    copy_mi = MenuItem.new(app._t(:copy).capitalize)
    copy_mi.get_style_class.add("code-area-context-menu-item")
    copy_mi.set_on_action {  |ev| edit_copy_item_clicked }

    paste_mi = MenuItem.new(app._t(:paste).capitalize)
    paste_mi.get_style_class.add("code-area-context-menu-item")
    paste_mi.set_on_action {  |ev| edit_paste_item_clicked }

    select_all_mi = MenuItem.new(app._t(:select_all).capitalize)
    select_all_mi.get_style_class.add("code-area-context-menu-item")
    select_all_mi.set_on_action {  |ev| edit_select_all_item_clicked }

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

    @code_editor.add_event_filter(MouseEvent::MOUSE_CLICKED) { |ev|
      if ev.button == MouseButton::SECONDARY
        @context_menu.show(@code_editor, ev.get_screen_x, ev.get_screen_y)
        ev.consume
      end
    }
  end

  def set_captions
    @file_menu.text = app._t(:file).capitalize
    @file_new_menu_item.text = app._t(:new).capitalize
    @file_load_menu_item.text = app._t(:load).capitalize
    @file_save_menu_item.text = app._t(:save).capitalize
    @file_close_app_menu_item.text = app._t(:exit).capitalize

    @edit_undo_menu_item.text = app._t(:undo).capitalize
    @edit_redo_menu_item.text = app._t(:redo).capitalize
    @edit_cut_menu_item.text = app._t(:cut).capitalize
    @edit_copy_menu_item.text = app._t(:copy).capitalize
    @edit_paste_menu_item.text = app._t(:paste).capitalize
    @edit_select_all_menu_item.text = app._t(:select_all).capitalize
    @edit_format_menu_item.text = app._t(:format_code).capitalize

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
               alert = Alert.new(Alert::AlertType::CONFIRMATION, app._t(:are_you_sure_to_overwrite).capitalize)
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
    if @executor.source_controller.empty?
      @filename = ''
      @executor.source_controller.code_set('')
    else
      alert = Alert.new(Alert::AlertType::CONFIRMATION, app._t(:are_you_sure_to_new).capitalize)
      alert.show_and_wait.filter { |response|
        response == ButtonType::OK
      }.ifPresent { |response|
        @filename = ''
        @executor.source_controller.code_set('')
      }
    end
  end

  def load_clicked
    if @executor.source_controller.saved?
      load_file(save_open_dialog)
    else
      alert = Alert.new(Alert::AlertType::CONFIRMATION, app._t(:are_you_sure_to_load).capitalize)
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
      :indent_token =>  " ",
      :indent_count => app.configs.fetch2([:tab_chars], '  ').size)
    @executor.source_controller.code_set(code)
  end

end
