module IWonder
  module AbTesting
    module ActionControllerMixins

      def self.included(base)
        base.class_eval do
          helper_method :which_test_group?
        end
      end
      
      def which_test_group?(event_sym)
        ab_test = IWonder::AbTest.find_by_sym(event_sym.to_s)
        raise "Not a valid test group" unless ab_test
        ab_test.which_test_group?(self)        
      end


    end
  end
end