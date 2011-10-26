# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111023231947) do

  create_table "accounts", :force => true do |t|
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "i_wonder_ab_tests", :force => true do |t|
    t.string   "name"
    t.string   "sym"
    t.text     "description"
    t.text     "options"
    t.text     "test_group_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "i_wonder_ab_tests", ["sym"], :name => "index_i_wonder_ab_tests_on_sym"

  create_table "i_wonder_events", :force => true do |t|
    t.string   "event_type"
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "session_id"
    t.string   "controller"
    t.string   "action"
    t.string   "remote_ip"
    t.string   "user_agent"
    t.string   "referrer"
    t.text     "extra_details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "i_wonder_events", ["account_id"], :name => "index_i_wonder_events_on_account_id"
  add_index "i_wonder_events", ["event_type"], :name => "index_i_wonder_events_on_event_type"
  add_index "i_wonder_events", ["session_id"], :name => "index_i_wonder_events_on_session_id"
  add_index "i_wonder_events", ["user_id"], :name => "index_i_wonder_events_on_user_id"

  create_table "i_wonder_metrics", :force => true do |t|
    t.string   "name"
    t.text     "options"
    t.text     "collection_method"
    t.boolean  "archived"
    t.integer  "frequency"
    t.datetime "earliest_measurement"
    t.datetime "last_measurement"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "i_wonder_report_memberships", :force => true do |t|
    t.integer "report_id"
    t.integer "metric_id"
  end

  add_index "i_wonder_report_memberships", ["metric_id"], :name => "index_i_wonder_report_memberships_on_metric_id"
  add_index "i_wonder_report_memberships", ["report_id"], :name => "index_i_wonder_report_memberships_on_report_id"

  create_table "i_wonder_reports", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "report_type"
    t.boolean  "pin_to_dashboard"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "i_wonder_snapshots", :force => true do |t|
    t.integer  "metric_id"
    t.integer  "count"
    t.text     "complex_data"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "i_wonder_test_group_memberships", :force => true do |t|
    t.integer  "ab_test_id"
    t.string   "member_type"
    t.string   "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "i_wonder_test_group_memberships", ["ab_test_id"], :name => "index_i_wonder_test_group_memberships_on_ab_test_id"
  add_index "i_wonder_test_group_memberships", ["member_type", "member_id"], :name => "i_wonder_test_group_memberships_member"

end
