IWonder::Engine.routes.draw do
  get "dashboard" => "dashboard#landing"

  resources :reports
  resources :metrics
  resources :events, :only => [:index, :show]
  
  root :to => "dashboard#landing"
end
