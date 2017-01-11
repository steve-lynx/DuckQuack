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
require 'yaml'
import javafx.geometry.Pos
import javafx.scene.layout.HBox
import org.fxmisc.richtext.LineNumberFactory

class SourceCodeController

  attr_reader :code_area
  attr_reader :gutter
  attr_reader :syntax_highlighter

  LINE_NUMBER_STYLE = 'linenumber'
  LINE_SYMBOL_STYLE = 'linesymbol'

  def initialize(code_area, code_area_info)    
    @code_area = code_area
    @code_area_info = code_area_info
    prepare_editing
  end

  def info(messages = {})
    append = messages.delete(:append)
    m = messages.map { |k,v| "#{app._t(k.to_sym)}: #{v}" }.join(" ")
    @code_area_info.text = append.nil? ? m : @code_area_info.text + ' - ' + m
  end

  def prepare_editing
    find_language
    @code_area.set_paragraph_graphic_factory(linenumber_and_symbols_factory)
    @syntax_highlighter = SyntaxHighlighter.new(
      @code_area, File.join(app.configs[:path][:editor], @language), app.configs[:highlighting])
  end

  def linenumber_and_symbols_factory
    -> (line) {
      @gutter = HBox.new(
        LineNumberFactory.get(@code_area).apply(line),
        SymbolFactory.new(@code_area, SyntaxHighlighter::LINE_ERROR_STYLE, LINE_SYMBOL_STYLE).apply(line)
      )
      @gutter.set_alignment(Pos::CENTER_LEFT)
      @gutter.get_children[0].get_style_class.add(LINE_NUMBER_STYLE)      
      @gutter
    }
  end
  private :linenumber_and_symbols_factory

  def substitutions_regex
    if @substitutions_regex.nil?
      regex = app._substitutions.keys.reduce([]) { |acc, k|
        acc << %((?<#{app._substitutions[k]}>#{Regexp.new(k.to_s)})); acc
      }.join('|')
      @substitutions_regex = Regexp.new(regex)
      @substitutions_regex
    else
      @substitutions_regex
    end
  end
  private :substitutions_regex
  
  def saved?
    @code_area.get_undo_manager.at_marked_position_property.get
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
    @syntax_highlighter.build_ast(code, substitutions_regex).each { |a|
      code.gsub!(Regexp.new('\b'+ a[1] +'\b'), a[0].to_s)
    }
    @source = code
  end
  private :preprocess_code

  def code_get
    @syntax_highlighter.reset_error_point
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
  end

  def empty?
    @code_area.get_length <= 0
  end
  
end
