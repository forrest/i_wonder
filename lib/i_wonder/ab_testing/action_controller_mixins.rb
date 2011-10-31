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
        return false unless ab_test

        if params[:_force_ab_test] and params[:_to_option] and params[:_force_ab_test]==event_sym.to_s
          return params[:_to_option]
        end
        
        ab_test.which_test_group?(self)
      end

    end
  end
end