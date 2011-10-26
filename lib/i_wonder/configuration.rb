module IWonder
  ALWAYS_AVOID_CONTROLLERS = ["i_wonder/dashboard", "i_wonder/reports", "i_wonder/metrics", "i_wonder/events"]
  
  def self.configuration
     @configuration ||= Configuration.new
   end

   def self.configure
     yield configuration
   end
  
  class Configuration
    attr_accessor :keep_hits_for, :only_log_hits_on_200, :back_to_app_link, :app_name
    attr_reader :controllers_to_ignore
    
    def initialize
      @keep_hits_for = 2.weeks
      @controllers_to_ignore = ALWAYS_AVOID_CONTROLLERS
      @only_log_hits_on_200 = true
      @back_to_app_link = "/"
      @app_name = "My App"
    end
    
    def controllers_to_ignore=(new_controllers)
      new_controllers = [new_controllers] unless new_controllers.is_a?(Array)
      @controllers = ALWAYS_AVOID_CONTROLLERS + new_controllers.collect(&:to_s)
      @controllers = @controllers.flatten.uniq
    end
    
  end
end