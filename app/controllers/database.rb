# encoding: utf-8

#for jruby-complete?
$LOAD_PATH.unshift PATH_ROOT
#
require 'sequel'

Sequel::Model.plugin(:schema)
Sequel::Model.plugin(:boolean_readers)
Sequel::Model.plugin(:validation_helpers)
Sequel::Model.raise_on_save_failure = false # Do not throw exceptions on failure

class Sequel::Model
  
  include AppHelpers
  
  def validate_date(date)
    unless values[date].blank?
      begin
        DateTime.parse(values[date]) if values[date].is_a?(String)
      rescue
        errors.add(date, I18n.t(:invalid_date))
      end
    end
  end
  
end
