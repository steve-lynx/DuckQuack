# encoding: utf-8

include Java
import java.lang.System

require 'jrubyfx'
require 'yaml'
import javafx.scene.layout.HBox
import javafx.geometry.Pos
import org.fxmisc.richtext.CodeArea
import org.fxmisc.richtext.LineNumberFactory
import org.fxmisc.richtext.StyledTextArea
import org.fxmisc.flowless.VirtualizedScrollPane
import org.fxmisc.richtext.model.StyleSpans
import org.fxmisc.richtext.model.StyleSpansBuilder

class SourceCodeController

  def initialize(codeArea)
    syntax_regex
    prepare_code_editor(codeArea)
    @preamble = [
      '#encoding: utf-8',
      'java_import javafx.scene.paint.Color',
      'java_import javafx.scene.shape.ArcType',
      'java_import javafx.scene.image.Image',
      'java_import javafx.scene.text.Font',
      'java_import javafx.scene.text.TextAlignment',
      'java_import javafx.geometry.VPos',
      'java_import javafx.geometry.HPos',
      'java_import javafx.scene.text.FontSmoothingType',
      'java_import javafx.scene.shape.StrokeLineCap',
      'java_import javafx.scene.shape.StrokeLineJoin',
      'java_import javafx.scene.shape.FillRule'
    ]
    @prelude = []
  end

  def prepare_grapics_factory
    number_factory = LineNumberFactory.get(@code_area)
    lambda { |line|
      hbox = HBox.new(number_factory.apply(line))
      hbox.set_alignment(Pos::CENTER_LEFT)
      hbox.setId("code-area-linenumber-box")
      label = hbox.get_children[0]
      label.get_style_class.add("linenumber");
      hbox
    }
  end

  def prepare_code_editor(code_area)
    @code_area = code_area
    @code_area.get_stylesheets.add('file://' + File.join(app.configs[:path][:config], 'syntax-specs.css'))
    @code_area.set_style_class(0,  @code_area.length, 'code-editor')    
    @code_area.set_paragraph_graphic_factory(prepare_grapics_factory)     
    @code_saved = @code_area.get_undo_manager.at_marked_position_property
   
    @code_area.richChanges
    .filter { |ch|  !ch.get_inserted.equals(ch.get_removed)}
    .subscribe { |change| @code_area.set_style_spans(0, highlight_code(@code_area.get_text)) }
    
  end
  private :prepare_code_editor

  def syntax_regex
    if defined?(@syntax_regex).nil?
      syntax_specs = YAML.load_file(File.join(app.configs[:path][:config], 'syntax-specs.yml'))
      regex = syntax_specs.keys.reduce([]) { |acc, k|
        words = syntax_specs[k].reduce([]) { |memo, w| memo << (w.size > 1 ? Regexp.new(w) : Regexp.escape(w) ); memo } 
        acc << %((?<#{k.to_s}>#{words.join('|')})); acc
      }.join('|')
      @syntax_regex = Regexp.new(regex)
    else
      @syntax_regex
    end
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
    spansBuilder.add(['default'], code.length - lastKwEnd);
    spansBuilder.create
  end
  private :highlight_code

  def saved?
    @code_saved.get
  end

  def changed?
    !saved?
  end
  
  def preamble
    @preamble.join("\n")
  end
  private :preamble

  def postamble
    ""
  end
  private :postamble

  def prelude(*lines)
    @prelude = lines
  end

  def code_text_get
    @code_area.get_text
  end
  
  def preprocess_code
    code = code_text_get
    build_ast(code, substitutions_regex).each { |a|
      code.gsub!(Regexp.new('\b'+ a[1] +'\b'), a[0].to_s)
    }
    @source = code
  end

  def code_get
    preprocess_code
    %(#{preamble}
      #{@prelude.join("\n")}
      #{@source}
      #{postamble})
  end 

  def code_set(code)
    @code_area.replaceText(0, @code_area.get_length, code)   
  end
  
end
