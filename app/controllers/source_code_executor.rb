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
require 'fileutils'
require 'facets'

import javafx.scene.control.TextArea
import javafx.scene.canvas.Canvas

class ExecutorController

  attr_reader :containers
  attr_reader :output
  attr_reader :canvas
  attr_reader :source_controller

  def initialize(containers, source_controller)
    @containers = containers
    @source_controller = source_controller
    find_output_areas
  end

  def stack_pane
    @containers[0]
  end

  def output_pane
    @containers[1]
  end

  def find_output_areas
    @canvas = stack_pane.getChildren.reduce { |m, child|
      child.is_a?(Canvas) ? child : nil
    }
    @canvas.widthProperty.bind(stack_pane.widthProperty)
    @canvas.heightProperty.bind(stack_pane.heightProperty)

    @output = output_pane.getChildren.reduce { |m, child|
      child.is_a?(TextArea) ? child : nil
    }
    @output.get_style_class.add("output-pane");
    @output.get_stylesheets.add('file://' + File.join(app.configs[:path][:config], 'output-pane.css'))
  end
  private :find_output_areas

  def run
    running_code = RunningCode.new(stack_pane, @source_controller, @canvas, @output)
    running_code.activate
    running_code = nil    
    System.gc #force garbage collection?
  end

end
