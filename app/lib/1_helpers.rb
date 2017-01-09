# encoding: utf-8

module AppHelpers
  include Logging

  def app
    $___running_app___
  end

  def set_app(a)
    $___running_app___ = a if $___running_app___.nil?
    $___running_app___
  end
  
end


