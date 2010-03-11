# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100311005504) do

  create_table "degrees", :force => true do |t|
    t.integer  "user_id"
    t.integer  "class_year", :default => 0
    t.string   "degree",     :default => ""
    t.string   "major",      :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school",     :default => "Stanford University"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "user_id"
    t.string   "company",          :default => ""
    t.string   "title",            :default => ""
    t.integer  "start_m",          :default => 0
    t.integer  "start_y",          :default => 0
    t.integer  "end_m",            :default => 0
    t.integer  "end_y",            :default => 0
    t.string   "job_current",      :default => "0"
    t.integer  "satisfaction",     :default => 0
    t.string   "responsibilities", :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", :force => true do |t|
    t.integer "liked_id"
    t.integer "liked_by_id"
  end

  create_table "logs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "ab_assignment"
    t.string   "url_visited"
    t.string   "time_visited"
    t.string   "temp_id"
  end

  create_table "masters", :force => true do |t|
    t.string   "logo_file"
    t.string   "pathways_logo"
    t.string   "informal_name"
    t.string   "formal_name"
    t.string   "self_description"
    t.string   "url"
    t.text     "alum_default_qs"
    t.text     "student_default_qs"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ab_last_assigned",   :default => 1
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "email_private",          :default => "0"
    t.string   "six_words",              :default => ""
    t.string   "is_alum",                :default => "0"
    t.text     "student_interview_text"
    t.text     "alum_interview_text"
    t.string   "video_url",              :default => ""
    t.datetime "interview_date",         :default => '2010-02-16 21:07:52'
    t.text     "summary",                :default => ""
    t.string   "image_file",             :default => "blank_profile_pic.jpg"
    t.integer  "author",                 :default => 0
    t.integer  "total_views",            :default => 0
    t.integer  "views",                  :default => 0
    t.integer  "likes",                  :default => 0
    t.string   "hashed_password"
    t.datetime "date_added",             :default => '2010-02-16 21:07:52'
    t.datetime "date_modified",          :default => '2010-02-16 21:07:52'
    t.datetime "question_asked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "approved",               :default => 0
    t.string   "editing_allowed",        :default => "1"
  end

end
