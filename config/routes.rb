Rails.application.routes.draw do
  scope "i_wonder", :as => "i_wonder" do
    get "/" => "i_wonder/dashboard#landing"
    get "dashboard" => "i_wonder/dashboard#landing"
    
    resources :reports, :controller => "i_wonder/reports"
    resources :metrics, :controller => "i_wonder/metrics"
    resources :events, :controller => "i_wonder/events", :only => [:index, :show]
  end

  
  # resources "i_wonder/metrics"#, :as => "i_wonder/metrics"
  # resources "i_wonder/events", :only => [:index, :show]#, :as => "i_wonder/events"
  
  # root :to => "dashboard#landing"
end
