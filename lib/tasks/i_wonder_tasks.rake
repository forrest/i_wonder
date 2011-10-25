task :cron => ["i_wonder:take_snapshots"]

namespace :i_wonder do  
  desc "Checks and runs any IWonder::Metrics which are overdue for a snapshot (hooks onto 'rake cron')"
  task :take_snapshots => :environment do
    IWonder::Metric.take_snapshots
  end
end