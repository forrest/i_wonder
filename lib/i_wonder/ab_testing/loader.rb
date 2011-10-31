module IWonder
  module AbTesting
    class Loader
      I_WONDER_DATA_DIR = Rails.root.join("i_wonder").to_s
      AB_TEST_DATA_DIR = File.join(I_WONDER_DATA_DIR,"ab_tests").to_s
      
      def self.save_ab_test(ab_test)
        Dir.mkdir(I_WONDER_DATA_DIR) unless File.exists?(I_WONDER_DATA_DIR) 
        Dir.mkdir(AB_TEST_DATA_DIR) unless File.exists?(AB_TEST_DATA_DIR)
        
        File.open(file_name(ab_test.sym), 'w') do |file|
          file.write ab_test.to_xml(:except => [:id, :created_at, :updated_at], :include => :ab_test_goals)
        end
      end
      
      def self.load_all
        Dir.open(AB_TEST_DATA_DIR) do |dir|
          dir.each{|file_name|
            if file_name =~ /(.+).xml/
              load_sym($1)
            end
          }
        end
      end
      
      def self.load_sym(ab_test_sym)
        if File.exists?(file_name(ab_test_sym))
          File.open(file_name(ab_test_sym), 'r') do |file|
            
            ab_test = AbTest.find_by_sym(ab_test_sym)
            ab_test ||= AbTest.new
            
            ab_test.from_xml(file.read)
            
            ab_test.save!
          end          
        end
      end
    
      def self.remove_file_for(ab_test)
        if File.exists?(file_name(ab_test.sym))
          File.delete(file_name(ab_test.sym))
        end
      end
    
    private
    
      def self.file_name(sym)
        AB_TEST_DATA_DIR + "/#{sym}.xml"
      end
    
    end
  end
end
