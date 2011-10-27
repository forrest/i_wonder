module IWonder
  module AbTesting
    module ActionControllerMixins

      def self.included(base)
        base.class_eval do
          helper_method :which_test_group?
        end
      end
      
      def which_test_group?(event_sym)
        test = IWonder::AbTest.find_by_sym(event_sym)
        
        # check if the current user/session/account is already in a group
        if(current_group = test.get_current_group(env, cookies))
          return current_group.name
        else
          
          # pick an options randomly
        
          # # put the user/session/account in the group
          
          # return result
        end
      end


    end
  end
end