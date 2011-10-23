Rails.application.routes.draw do
  match "test_without_report" => "test#test_without_report"
  match "test_with_report" => "test#test_with_report"
  match "test_without_login" => "test#test_without_login"
  

  mount IWonder::Engine => "/i_wonder"
end
