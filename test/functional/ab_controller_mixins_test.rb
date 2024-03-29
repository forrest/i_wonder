require File.expand_path("../test_helper.rb", File.dirname(__FILE__))

class ABControllerMixinsTest < ActionController::TestCase
  tests TestController

  def setup
    IWonder::AbTest.delete_all
    
    @controller.instance_eval do
      cookies[IWonder::COOKIE_KEY+IWonder::Logging::SESSION_KEY_NAME] = "2"
      i_wonder_for_user_id("3")
      i_wonder_for_account_id("4")
    end
  end

  test "fetching the correct group" do
    @ab_test = Factory(:ab_test)
    @ab_test.update_attribute(:test_applies_to, "session")
    assert_valid @ab_test
    
    # add a random sesison, user and account to groups in this test
    @ab_test.test_group_memberships.create!(:member_type => "account", :member_id => "random_1", :test_group_name => "Options 1")
    @ab_test.test_group_memberships.create!(:member_type => "user", :member_id => "random_2", :test_group_name => "Options 1")
    @ab_test.test_group_memberships.create!(:member_type => "session", :member_id => "random_3", :test_group_name => "Options 1")
    
    assert_nil @ab_test.send(:get_current_group, @controller)
    
    t1 = @ab_test.test_group_memberships.create!(:member_type => "session", :member_id => "2", :test_group_name => "Option 2")
    assert_equal t1, @ab_test.send(:get_current_group, @controller)
    
    @ab_test.update_attribute(:test_applies_to, "user")
    assert_nil @ab_test.send(:get_current_group, @controller)
    t2 = @ab_test.test_group_memberships.create!(:member_type => "user", :member_id => "3", :test_group_name => "Option 2")
    assert_equal t2, @ab_test.send(:get_current_group, @controller)
    
    @ab_test.update_attribute(:test_applies_to, "account")
    assert_nil @ab_test.send(:get_current_group, @controller)
    t3 = @ab_test.test_group_memberships.create!(:member_type => "account", :member_id => "4", :test_group_name => "Option 2")
    assert_equal t3, @ab_test.send(:get_current_group, @controller)
  end  
  
  test "adding to test groups" do
    @ab_test = Factory(:ab_test)
    @ab_test.update_attribute(:test_applies_to, "session")
    assert_valid @ab_test
    
    assert_nil @ab_test.test_group_memberships.where(:member_type => "session", :member_id => "2", :test_group_name => "Option 2").first
    @ab_test.send(:add_to_test_group, "Option 2", @controller)
    assert @ab_test.test_group_memberships.where(:member_type => "session", :member_id => "2", :test_group_name => "Option 2").first
    
    @ab_test.update_attribute(:test_applies_to, "user")
    assert_nil @ab_test.test_group_memberships.where(:member_type => "user", :member_id => "3", :test_group_name => "Option 2").first
    @ab_test.send(:add_to_test_group, "Option 2", @controller)
    assert @ab_test.test_group_memberships.where(:member_type => "user", :member_id => "3", :test_group_name => "Option 2").first
        
    @ab_test.update_attribute(:test_applies_to, "account")
    assert_nil @ab_test.test_group_memberships.where(:member_type => "account", :member_id => "4", :test_group_name => "Option 2").first
    @ab_test.send(:add_to_test_group, "Option 2", @controller)
    assert @ab_test.test_group_memberships.where(:member_type => "account", :member_id => "4", :test_group_name => "Option 2").first
  end

  test "if which_test_group works" do
    @ab_test = Factory(:ab_test)
    @ab_test.update_attribute(:test_applies_to, "session")
    
    assert_equal 0, @ab_test.test_group_memberships.count
    
    # first time shouldn't be in a group yet. Will get placed in one.
    first_group = @controller.which_test_group?(@ab_test.sym)
    assert_include @ab_test.test_group_names, first_group
    assert_equal 1, @ab_test.test_group_memberships.count
    
    second_group = @controller.which_test_group?(@ab_test.sym)
    assert_include first_group, second_group
    assert_equal 1, @ab_test.test_group_memberships.count
  end
  
  test "which_test_group doesn't barf on missing member" do
    @ab_test = Factory(:ab_test)
    @ab_test.update_attribute(:test_applies_to, "session")
    
    @controller.instance_eval do
      cookies[IWonder::COOKIE_KEY+IWonder::Logging::SESSION_KEY_NAME] = nil
      cookies.delete(IWonder::COOKIE_KEY+IWonder::Logging::SESSION_KEY_NAME)
    end
    
    assert_equal 0, @ab_test.test_group_memberships.count
    assert @controller.which_test_group?(@ab_test.sym).present?, "something should still be returned"
    assert_equal 0, @ab_test.test_group_memberships.count, "Shuold not have made a memberhsip"
  end
  
  test "the element the test applies to is not available" do
    pending
  end
  
  test "which_test_group returns false when test is missing" do
    assert !@controller.which_test_group?("non-existant test")
  end
  
  test "forcing a choice with paramteres" do
    @ab_test = Factory(:ab_test, :sym => "override_test")
    assert_valid @ab_test
    
    @controller.params[:_force_ab_test] = "override_test"
    @controller.params[:_to_option] = "yah, it worked!"
    assert_equal "yah, it worked!", @controller.which_test_group?("override_test")
  end
  
end
