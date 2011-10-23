class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # before_filter :check_for_admin
  # def check_for_admin
  #   unless params[:controller] =~ /test/
  #     flash[:error] = "Authentication check occurred"
  #     redirect_to main_app.root_url
  #   end
  # end
  
end
