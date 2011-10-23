require "i_wonder/engine"
require 'i_wonder/core_ext'
require "i_wonder/configuration"

module IWonder
  
  module Logging
    ENV_KEY = COOKIE_KEY = "i_wonder"
    SESSION_KEY_NAME = "_session_id"
    
    autoload :Middleware, 'i_wonder/logging/middleware'
    autoload :ActionControllerMixins, 'i_wonder/logging/mixins/action_controller_mixins'
    autoload :ActiveRecordMixins, 'i_wonder/logging/mixins/active_record_mixins'
  end


end