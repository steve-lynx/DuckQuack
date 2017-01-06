# encoding: utf-8

include Java
import java.lang.System

require 'jrubyfx'
require 'yaml'
import javafx.scene.layout.HBox
import javafx.geometry.Pos
import javafx.scene.Node;
import org.fxmisc.richtext.CodeArea
import org.fxmisc.richtext.LineNumberFactory
import org.fxmisc.richtext.StyledTextArea
import org.fxmisc.flowless.VirtualizedScrollPane
import org.fxmisc.richtext.model.StyleSpans
import org.fxmisc.richtext.model.StyleSpansBuilder
import javafx.scene.shape.Polygon
import javafx.scene.shape.Ellipse
import org.reactfx.value.Val
import org.fxmisc.richtext.model.NavigationActions

class SymbolFactory
  
  java_implements "IntFunction<Node>"

  def initialize(code_area, error_style, line_style)
    @code_area = code_area
    @error_style = error_style
    @error_symbol = ["\u25b6", @error_style + "symbol"]
    @line_symbol = ["\u25b6", line_style]
  end

  def symbol(line_number)
    spans = @code_area.get_paragraph(line_number).get_style_spans
    error = spans.find { |sp| sp.get_style == [@error_style] }
    error ? @error_symbol : @line_symbol
  end
  private :symbol

  def apply(line_number)
    s = symbol(line_number)
    @indicator = Label.new(s[0])
    @indicator.get_style_class.add(s[1])    
    visible = Val.map(@code_area.current_paragraph_property) { |sl| sl == line_number }
    @indicator.visible_property.bind(
      Val.flat_map(@indicator.scene_property) { |scene|
        scene != nil ? visible : Val.constant(false)
      })
    @indicator
  end
end

class SourceCodeController

  attr_reader :code_area
  attr_reader :gutter

  def initialize(code_area, code_area_info)
    @lineerror_style = 'lineerror'
    @linenumber_style = 'linenumber'
    @linesymbol_style = 'linesymbol'
    @code_area = code_area
    @code_area_info = code_area_info
    reset_error_point
    prepare_editing
  end

  def info(messages = {})
    append = messages.delete(:append)
    m = messages.map { |k,v| "#{app._t(k.to_sym)}: #{v}" }.join(" ")
    @code_area_info.text = append.nil? ? m : @code_area_info.text + ' - ' + m
  end

  def prepare_editing
    find_language
    @syntax_specs = YAML.load_file(File.join(app.configs[:path][:editor], @language, 'syntax-specs.yml'))
    @comment_tag = @syntax_specs['comments'][0].gsub(".*$", '')
    @syntax_css = 'file://' + File.join(app.configs[:path][:editor], @language, 'syntax-specs.css')
    syntax_regex
    prepare_code_editor
  end

  def prepare_grapics_factory
    linenumbers = LineNumberFactory.get(@code_area)
    linesymbols = SymbolFactory.new(@code_area, @lineerror_style, @linesymbol_style)
    lambda { |line|
      @gutter = HBox.new(linenumbers.apply(line), linesymbols.apply(line))
      @gutter.set_alignment(Pos::CENTER_LEFT)
      line_number = gutter.get_children[0]
      line_number.get_style_class.add(@linenumber_style)      
      @gutter
    }
  end
  private :prepare_grapics_factory

  def set_error_point(point, c = "E")
    @current_error = @code_area.get_paragraph(point)    
    @code_area.insert_text(point, @current_error.length, " #{@comment_tag} <#{app._t(:error_line_comment)}>")
    code_area.move_to(point, 0)
  end

  def reset_error_point
    @current_error = nil
  end
  private :reset_error_point

  def error_point?
    !@current_error.nil?
  end
  private :error_point?
  
  def prepare_code_editor
    @code_area.get_stylesheets.add(@syntax_css)
    @code_area.set_style_class(0,  @code_area.length, 'code-editor')    
    @code_area.set_paragraph_graphic_factory(prepare_grapics_factory)     
    @code_saved = @code_area.get_undo_manager.at_marked_position_property    
    @code_area.richChanges
    .filter { |change|
      !change.get_inserted.equals(change.get_removed)
    }
    .subscribe { |change|
      @code_area.set_style_spans(0, highlight_code(@code_area.get_text)) 
    }    
  end
  private :prepare_code_editor

  def error_regex
    line =  Regexp.escape(@current_error.get_text)
    name = "lineerror"      
    "(?<#{name}>#{line})"
  end
  private :error_regex
  
  def syntax_regex
    regexs = @syntax_specs.keys.reduce([]) { |acc, k|
      words = @syntax_specs[k].reduce([]) { |memo, w|
        memo << (w.size > 1 ? Regexp.new(w) : Regexp.escape(w) );
        memo
      } 
      acc << %((?<#{k.to_s}>#{words.join('|')})); acc
    }
    regexs.insert(0, error_regex) if error_point?
    @syntax_regex = Regexp.new(regexs.join('|'))
    @syntax_regex
  end
  private :syntax_regex

  def substitutions_regex
    if defined?(@substitutions_regex).nil?
      substitutions = app._substitutions
      regex = substitutions.keys.reduce([]) { |acc, k|
        acc << %((?<#{substitutions[k]}>#{Regexp.new(k.to_s)})); acc
      }.join('|')
      @substitutions_regex = Regexp.new(regex)
    else
      @substitutions_regex
    end
  end
  private :substitutions_regex

  def build_ast(code, regex)
    matches = code.to_enum(:scan, regex).map { Regexp.last_match }
    matches.reduce([]) { |memo, matcher|
      names = matcher.names
      memo << names.size.times.reduce([]) { |acc, index|
        name =  names[index].to_sym
        acc = [name, matcher[name], matcher.begin(name), matcher.end(name)] unless matcher[name].nil?
        acc
      }      
      memo
    }
  end
  private :build_ast
  
  def highlight_code(code = '')
    spansBuilder = StyleSpansBuilder.new
    lastKwEnd = 0
    build_ast(code, syntax_regex).each { |a|
      spansBuilder.add(['default'], a[2] - lastKwEnd)            
      spansBuilder.add([a[0].to_s], a[3] - a[2])
      lastKwEnd = a[3]
    }
    spansBuilder.create
  end
  private :highlight_code

  def saved?
    @code_saved.get
  end

  def changed?
    !saved?
  end
  
  def code_text_get
    @code_area.get_text
  end

  def find_language
    code = code_text_get
    regex = %r{^.*-\*-(.*)-\*-$}
    m = code.match(regex)
    @language = m.nil? ? app.configs[:language] : m[1].strip
    logger.debug("LANGUAGE: #{@language}")
    info(:language => @language.capitalize)
    code
  end
  
  def preprocess_code
    code = find_language
    build_ast(code, substitutions_regex).each { |a|
      code.gsub!(Regexp.new('\b'+ a[1] +'\b'), a[0].to_s)
    }
    @source = code
  end
  private :preprocess_code

  def code_get
    reset_error_point
    preprocess_code
    syntax_code = YAML.load_file(File.join(app.configs[:path][:editor], @language, 'code.yml'))
    preamble = syntax_code['preamble'].join("\n")
    postamble = syntax_code['postamble'].join("\n")
    code =
      %(#{preamble}
      #{@source}
      #{postamble})
    logger.debug("\nBEGIN CODE (#{@language}):\n#{code}\nEND CODE")
    {:code => code, :preamble_size => syntax_code['preamble'].size, :postamble_size => syntax_code['postamble'].size} 
  end 

  def code_set(code)
    @code_area.replaceText(0, @code_area.get_length, code)
    find_language
    prepare_editing
  end

  def empty?
    @code_area.get_length <= 0
  end
  
end
