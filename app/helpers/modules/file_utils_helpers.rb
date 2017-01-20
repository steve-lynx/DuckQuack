# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

module FileUtilsHelpers

  require 'fileutils'

  def pwd
    FileUtils.pwd
  end

  def open_file(filename)
    c = ''
    File.open(filename, 'r') { |f| c = f.read}
    c
  end

end
