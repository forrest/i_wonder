IWonder::Engine.routes.draw do
  get "dashboard" => "dashboard#landing"

  resources :ab_tests
  resources :reports
  resources :metrics
  resources :events, :only => [:index, :show]
  
  root :to => "dashboard#landing"
end
