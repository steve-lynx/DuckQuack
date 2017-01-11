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
import org.fxmisc.richtext.model.StyleSpans
import org.fxmisc.richtext.model.StyleSpansBuilder

import java.time.Duration
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javafx.concurrent.Task
import java.util.Optional

class SyntaxHighlighter

  attr_reader :code_area

  LINE_ERROR_STYLE = 'lineerror'
  DEFAULT_STYLE = 'default'
  CODE_AREA_STYLE = 'code-editor'

  def initialize(code_area, path, highlighting = {})
    @highlighting = { :async => false, :time => 500 }.deep_merge(highlighting)
    @code_area = code_area
    @syntax_specs = YAML.load_file(File.join(path, 'syntax-specs.yml'))
    @syntax_css = 'file://' + File.join(path, 'syntax-specs.css')
    @code_area.get_stylesheets.add(@syntax_css)
    @code_area.set_style_class(0,  @code_area.length, CODE_AREA_STYLE)   
    @comment_tag = @syntax_specs['comments'][0].gsub(".*$", '')
    reset_error_point
    syntax_regex
    @highlighting[:async] ? syntax_activate_async : syntax_activate    
  end

  def syntax_activate_async
    @executor = Executors.newSingleThreadExecutor
    ExecutorsPool.set({ :c => 'SyntaxHighlighterAsync', :e => @executor, :t => 'SingleThreadExecutor'})
    @code_area.richChanges
    .filter(-> (change) { !change.get_inserted.equals(change.get_removed) })
    .successionEnds(Duration.ofMillis(@highlighting[:time]))
    .supplyTask(-> { compute_highlighting_async })
    .awaitLatest(@code_area.richChanges)
    .filterMap(-> (t) { t.isSuccess ? Optional.of(t.get) : Optional.empty })
    .subscribe(-> (highlighting) { @code_area.set_style_spans(0, highlighting) })
  end
  private :syntax_activate_async

  def syntax_activate
    @code_area.richChanges
    .filter { |change| !change.get_inserted.equals(change.get_removed) }
    .subscribe { |change|
      @code_area.set_style_spans(0, highlight_code(@code_area.get_text)) 
    }    
  end
  private :syntax_activate

  class TaskHighlighting < Java::javafx.concurrent.Task
    attr_accessor :caller
    def call
      #@caller.highlight_code(@caller.code_area.get_text)
      @caller.send(:highlight_code, @caller.code_area.get_text)
    end
  end

  def compute_highlighting_async
    task = TaskHighlighting.new
    task.caller = self
    @executor.execute(task)
    task
  end
  private :compute_highlighting_async

  def syntax_regex
    if @syntax_regexs.nil? || @syntax_regexs.empty?
      @syntax_regexs = @syntax_specs.keys.reduce([]) { |acc, k|
        words = @syntax_specs[k].reduce([]) { |memo, w|
          memo << (w.size > 1 ? Regexp.new(w) : Regexp.escape(w) );
          memo
        } 
        acc << %((?<#{k.to_s}>#{words.join('|')})); acc
      }
      logger.debug(@syntax_regexs)
    end
    Regexp.new(@syntax_regexs.join('|'))
  end
  private :syntax_regex  

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
  #private :build_ast
  
  def highlight_code(code = '')
    spansBuilder = StyleSpansBuilder.new
    lastKwEnd = 0
    build_ast(code, syntax_regex).each { |a|
      spansBuilder.add([DEFAULT_STYLE], a[2] - lastKwEnd)            
      spansBuilder.add([a[0].to_s], a[3] - a[2])
      lastKwEnd = a[3]
    }
    spansBuilder.create
  end
  private :highlight_code

  def error_regex
    line =  Regexp.escape(@current_error.get_text)     
    "(?<#{LINE_ERROR_STYLE}>#{line})"
  end
  private :error_regex

  def set_error_point(point, cause)
    logger.debug("ERROR POINT: #{ point + 1}")
    @current_error = @code_area.get_paragraph(point) 
    @syntax_regexs.insert(0, error_regex) if error_point?    
    code_area.move_to(point, 0)
    #@code_area.insert_text(point, @current_error.length, " #{@comment_tag} <#{app._t(:error_line_comment)}>")
    @code_area.replace_text(point, 0, point, @current_error.length, @current_error.get_text)
  end

  def reset_error_point    
    @syntax_regexs.slice!(0) if error_point?
    @current_error = nil
  end

  def error_point?
    !@current_error.nil?
  end
  
end
