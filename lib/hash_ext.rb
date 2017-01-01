# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

require 'facets/hash/deep_rekey'
require 'facets/hash/reverse_merge'
require 'facets/hash/deep_merge'

class Hash

  def fetch2(keys, default = nil)    
    result = self.fetch(keys.delete_at(0), default)
    keys.each { |k| result = result.fetch(k, default) if result.is_a?(Hash) }
    result
  end unless method_defined?(:fetch2)
  
end
