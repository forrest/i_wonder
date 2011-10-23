class TestController < ApplicationController
  before_filter :set_user_and_admin, :except => :test_without_login
  
  def test_without_report
    render :nothing => true
  end
  
  def test_with_report
    report! :test_event
    render :nothing => true
  end
  
  
  def test_without_login
    render :nothing => true
  end
  
  protected
  
  def set_user_and_admin
    i_wonder_for_user_id 2
    i_wonder_for_account_id 3
  end
  
end
