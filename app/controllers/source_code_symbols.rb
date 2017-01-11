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
import org.reactfx.value.Val
import javafx.scene.control.Label

class SymbolFactory
  
  java_implements "IntFunction<Node>"

  def initialize(code_area, error_style, line_style)
    @code_area = code_area
    @error_style = error_style
    @error_symbol = ["\u25b6", @error_style + "symbol"]
    @line_symbol = ["\u25b6", line_style]
    @syntax_regexs = nil
    @substitutions_regex = nil
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
