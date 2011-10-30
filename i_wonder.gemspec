$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "i_wonder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "i_wonder"
  s.version     = IWonder::VERSION
  s.authors     = ["Forrest Zeisler"]
  s.email       = ["development@forrestzeisler.com"]
  s.homepage    = "http://github.com/forrest/i_wonder"
  s.summary     = "Read \"The Lean Startup\" and got inspired."
  s.description = "Analytics and AB Testing awesomeness for rails."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.1"
  s.add_dependency "jquery-rails"
  s.add_dependency 'delayed_job', '~> 2.1'
  s.add_dependency 'hash_accessor', '~> 1.0'


  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "pg"
  s.add_development_dependency "pry"
  s.add_development_dependency "sass", '~> 3.1'
  s.add_development_dependency "timecop"
  s.add_development_dependency "mocha"
  
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
end
