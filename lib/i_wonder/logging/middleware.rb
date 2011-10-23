module IWonder
  module Logging
    class Middleware
      NO_USER_KEY = "_no_user"
      BOT_REGEX = /msnbot|yahoo|slurp|googlebot/
      
      def initialize(app)
        @app = app
      end

      def call(env)
        env[ENV_KEY] = {}
        @status, @headers, @response = @app.call(env)
        
        if should_be_logged?(env)
          
          unless env['User-Agent'] =~ BOT_REGEX
            env["rack.session"] ||= {}
            process_env(env)
          end
        end

        [@status, @headers, @response]
      end
      
    private
      
      def process_env(env)
        check_for_new_visitor(env) # this will set the i_wonder_session_id if blank. This session is needed later
        log_hit(env)
        merge_session_to_user(env)
        generate_any_reported_events(env)
      end
      
      def log_hit(env)
        env[ENV_KEY]["new_events"] ||= []
        env[ENV_KEY]["new_events"] << {:event_type => :hit}
      end
      
      def check_for_new_visitor(env)
        if cookies(env)[COOKIE_KEY+SESSION_KEY_NAME].blank?
          cookies(env).permanent[COOKIE_KEY+SESSION_KEY_NAME] = SecureRandom.hex(10)
          env[ENV_KEY]["new_events"] ||= []
          env[ENV_KEY]["new_events"] << {:event_type => :new_visitor}
        end
      end
      
      def generate_any_reported_events(env)
        IWonder::Event.transaction do # this means that it will send all the SQL to the db at once
          (env[ENV_KEY]["new_events"] || []).each{|report_hash|
            IWonder::Event.fast_create(clean_options(env, report_hash))
          }
        end
      end
      
      def merge_session_to_user(env)
        if env[ENV_KEY]["user_id"] # if there is a user
          if cookies(env)[COOKIE_KEY+NO_USER_KEY].present? # if there wasn't a user last hit
            if cookies(env)[COOKIE_KEY+SESSION_KEY_NAME].present? # There should always be a session key, but better to check
              IWonder::Event.merge_session_to_user(cookies(env)[COOKIE_KEY+SESSION_KEY_NAME], env[ENV_KEY]["user_id"])
            end
            cookies(env)[COOKIE_KEY+NO_USER_KEY] = nil
            cookies(env).delete(COOKIE_KEY+NO_USER_KEY)
          end
        else
          cookies(env)[COOKIE_KEY+NO_USER_KEY] = "1"
        end
      end
      
      def clean_options(env, options)
        options[:user_id] = env[ENV_KEY]["user_id"] if env[ENV_KEY]["user_id"]
        options[:account_id] = env[ENV_KEY]["account_id"] if env[ENV_KEY]["account_id"]
        
        if cookies(env)[COOKIE_KEY+SESSION_KEY_NAME].present?
          options[:session_id] = cookies(env)[COOKIE_KEY+SESSION_KEY_NAME]
        end
        
        if env["action_dispatch.request.parameters"]
          options[:controller] = env["action_dispatch.request.parameters"][:controller]
          options[:action] = env["action_dispatch.request.parameters"][:action]
        end
        
        request = Rack::Request.new(env)
        options[:user_agent] = env["User-Agent"].to_s.downcase if env["User-Agent"]
        options[:referrer] = request.referrer if request.referrer.present?
        options[:remote_ip] = env["action_dispatch.remote_ip"].to_s

        return options
      end
      
      def cookies(env)
        env["action_dispatch.cookies"] ||= ActionDispatch::Request.new(env).cookie_jar
      end
      
      def controller(env)
        env["action_dispatch.request.parameters"] and env["action_dispatch.request.parameters"][:controller]
      end
      
      def should_be_logged?(env)
        controller(env) and !IWonder.configuration.controllers_to_ignore.include?(controller(env))
      end
      
    end
  end
end
