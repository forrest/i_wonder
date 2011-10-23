# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


require "factory_girl_rails"
Dir.open(File.expand_path("factories/", File.dirname(__FILE__))).each{|file_name|
  require File.expand_path("factories/#{file_name}", File.dirname(__FILE__)) if file_name =~ /.*_factory.rb/
}