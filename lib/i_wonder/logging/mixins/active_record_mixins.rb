module IWonder
  module Logging
    module ActiveRecordMixins

      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def report!(event_sym, options = {})
        self.class.report!(event_sym, options)
      end

      module ClassMethods
        def report!(event_sym, options = {})
          # TODO: this can skip activerecord and write directly for performance
          options ||= {}
          options[:event_type] = event_sym.to_s
          IWonder::Event.create(options)
        end
      end

    end
  end
end