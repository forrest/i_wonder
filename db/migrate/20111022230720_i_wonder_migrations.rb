class IWonderMigrations < ActiveRecord::Migration
  def change
    create_table :i_wonder_events do |t|
      t.string :event_type
      t.integer :account_id # not always applicable
      t.integer :user_id # not always applicable
      t.string :session_id
      t.string :controller
      t.string :action
      t.string :remote_ip
      t.string :user_agent
      t.string :referrer
      t.text :extra_details
      t.timestamps
    end
    add_index :i_wonder_events, :event_type
    add_index :i_wonder_events, :account_id
    add_index :i_wonder_events, :user_id
    add_index :i_wonder_events, :session_id
    
    
    create_table :i_wonder_reports do |t|
      t.string :name
      t.text :description
      t.string :report_type # line, pie, test
      t.timestamps
    end
    
    create_table :i_wonder_report_memberships do |t|
      t.integer :report_id
      t.integer :metric_id
    end
    add_index :i_wonder_report_memberships, :report_id
    add_index :i_wonder_report_memberships, :metric_id
    
    
    # used for line and pie charts
    create_table :i_wonder_metrics do |t|
      t.string :name
      t.text :options
      
      t.text :collection_method
      t.boolean :archived
      
      t.integer :frequency # -1 means that it calculates on demand
      t.timestamp :earliest_measurement
      t.timestamp :last_measurement
      
      t.timestamps
    end
    
    create_table :i_wonder_snapshots do |t|
      t.integer :metric_id
      t.integer :count
      t.text :complex_data
      t.timestamp :start_time
      t.timestamp :end_time
      t.timestamps
    end
    
        # 
        # 
        # # used for A/B tests
        # create_table :iw_test_metrics do |t|
        #   t.string :name
        #   t.string :sym
        #   t.integer :iw_report_id
        #   t.boolean :account_wide, :default => false
        # end
        # add_index :iw_test_metrics, :iw_report_id
        # add_index :iw_test_metrics, :sym
        # 
        # 
        # create_table :iw_test_group_members do |t|
        #   t.integer :iw_report_id
        #   t.integer :iw_test_metric_id
        #   
        #   # One of these
        #   t.string :session_id
        #   t.integer :user_id
        #   t.integer :account_id
        # end
        # add_index :iw_test_group_members, :iw_test_metric_id
        # add_index :iw_test_group_members, :user_id
        # add_index :iw_test_group_members, :account_id
        # add_index :iw_test_group_members, :session_id
  end
end