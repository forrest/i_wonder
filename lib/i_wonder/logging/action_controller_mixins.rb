module IWonder
  module Logging
    module ActionControllerMixins

      def report!(event_sym, options = {})
        options ||= {}
        options[:event_type] = event_sym.to_s # it will get converted when stored anyways.
        
        self.request.env[ENV_KEY] ||= {} # this is for when the middleware doesn't get run first
        self.request.env[ENV_KEY]["new_events"] ||= []
        self.request.env[ENV_KEY]["new_events"] << options
      end

      def i_wonder_for_user_id(user_id)
        self.request.env[ENV_KEY] ||= {} # this is for when the middleware doesn't get run first
        self.request.env[ENV_KEY]["user_id"] = user_id.to_s
      end

      def i_wonder_for_account_id(account_id)
        self.request.env[ENV_KEY] ||= {} # this is for when the middleware doesn't get run first
        self.request.env[ENV_KEY]["account_id"] = account_id.to_s
      end
      
      def i_wonder_for_session_id(session_id)
        self.request.env[ENV_KEY] ||= {} # this is for when the middleware doesn't get run first
        self.request.env[ENV_KEY]["session_id"] = session_id.to_s
      end

    end
  end
end