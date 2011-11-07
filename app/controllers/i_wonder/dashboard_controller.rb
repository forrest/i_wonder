module IWonder
  class DashboardController < ApplicationController
    layout "i_wonder"
    
    if defined?(newrelic_ignore)
      newrelic_ignore
    end
    
    def landing
    end
    
  end
end
