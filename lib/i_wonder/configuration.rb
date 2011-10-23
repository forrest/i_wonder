module IWonder
  def self.configuration
     @configuration ||= Configuration.new
   end

   def self.configure
     yield configuration
   end
  
  class Configuration
    attr_accessor :keep_hits_for
    attr_reader :controllers_to_ignore
    
    def initialize
      @keep_hits_for = 2.weeks
      @controllers_to_ignore = []
    end
    
    def controllers_to_ignore=(controllers)
      @controllers = [controllers] unless controllers.is_a?(Array)
      @controllers = @controllers.collect(&:to_sym)
    end
    
  end
end