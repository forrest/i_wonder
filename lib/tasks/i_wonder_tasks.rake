task :cron => ["i_wonder:take_snapshots"]

namespace :i_wonder do  
  desc "Checks and runs any IWonder::Metrics which are overdue for a snapshot (hooks onto 'rake cron')"
  task :take_snapshots => :environment do
    
    original_timezone = Time.zone
    Time.zone = "UTC" # this should get set in a config
    IWonder::Metric.take_snapshots
    Time.zone = original_timezone
  end
end