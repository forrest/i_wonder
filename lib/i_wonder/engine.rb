module IWonder
  class Engine < Rails::Engine
    # This is for the mounting the engine ===========
    isolate_namespace IWonder
    
    initializer "i_wonder.loading_tests" do |app|
      
      # can't load if it's migrating the db
      unless ( File.basename($0) == "rake" && ARGV.include?("db:migrate") )
        ActiveRecord::Base.send :include, HashAccessor # this is to avoid load order issues from a required gem
        AbTesting::Loader.load_all
      end
    end
    
  end
end



class Railtie < Rails::Railtie
  # This is for extending the base rails aplication ===========

  initializer "i_wonder.add_logging_middleware" do |app|    
    app.middleware.insert_after ActionDispatch::ParamsParser, IWonder::Logging::Middleware
  end

  config.to_prepare do
    ApplicationController.send :include, IWonder::Logging::ActionControllerMixins
    ApplicationController.send :include, IWonder::AbTesting::ActionControllerMixins
    
    ActiveRecord.send :include, IWonder::Logging::ActiveRecordMixins
  end

end
