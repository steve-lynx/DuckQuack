# encoding: utf-8
######################################################################################
ENV['APP_ENV'] ||= 'development'

require 'pathname'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

PATH_ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))
PATH_APP = File.join(PATH_ROOT, 'app')
$LOAD_PATH << PATH_APP unless $LOAD_PATH.include?(PATH_APP)
PATH_LIB = File.join(PATH_ROOT, 'lib')

require 'rubygems'
require 'bundler/setup'

Dir[File.join(File.join(PATH_ROOT, 'lib'), '*.{rb,jar}')].sort.each { |h| p h; require(h) }

require 'duck_quack'

######################################################################################
