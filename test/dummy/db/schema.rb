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

ActiveRecord::Schema.define(:version => 20111022230720) do

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
    t.text     "collection_method"
    t.integer  "frequency"
    t.datetime "last_measurement"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "i_wonder_snapshots", :force => true do |t|
    t.integer  "metric_id"
    t.integer  "count"
    t.text     "complex_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
