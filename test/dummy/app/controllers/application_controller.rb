class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_for_admin
  def check_for_admin
    if params[:controller] =~ /i_wonder/ and params[:block_this].present?
      flash[:error] = "Authentication check occurred"
      redirect_to "/"
    end
  end
  
end
