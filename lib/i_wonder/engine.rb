module IWonder
  class Engine < Rails::Engine
    # This is for the mounting the engine ===========
    
#    isolate_namespace IWonder
  end
end



class Railtie < Rails::Railtie
  # This is for extending the base rails aplication ===========

  initializer "i_wonder.add_logging_middleware" do |app|    
    app.middleware.insert_after ActionDispatch::ParamsParser, IWonder::Logging::Middleware
  end

  config.to_prepare do
    ApplicationController.send :include, IWonder::Logging::ActionControllerMixins
    ActiveRecord.send :include, IWonder::Logging::ActiveRecordMixins
  end

end
