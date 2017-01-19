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

import java.time.Duration
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javafx.concurrent.Task
import java.util.Optional


require 'sinatra/base'

module HttpHelpers  

  class HttpServer < Sinatra::Base
    
    set :port, 3000
    set :host, '0.0.0.0'

    get '/kill' do
      Process.kill('TERM', Process.pid)   
    end

    get '/stop' do
      Process.kill('TERM', Process.pid)   
    end

  end
  
end
