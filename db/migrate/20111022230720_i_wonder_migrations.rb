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
      t.boolean :pin_to_dashboard
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
    
    create_table :i_wonder_ab_tests do |t|
      t.string :name
      t.string :sym
      t.text :description

      t.test :options # serialized
      t.text :test_group_data # serialized
      
      t.timestamps
    end
    add_index :i_wonder_tests, :sym
    
    
    create_table :i_wonder_test_group_memberships do |t|
      t.integer :ab_test_id
      
      t.string :member_type
      t.string :member_id

      t.timestamps
    end
    add_index :i_wonder_test_group_memberships, :ab_test_id
    add_index :i_wonder_test_group_memberships, [:member_type, :member_id], :name => "i_wonder_test_group_memberships_member"
   
  end
end