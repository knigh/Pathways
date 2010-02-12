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

ActiveRecord::Schema.define(:version => 20100207031433) do

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

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "email_private",          :default => "0"
    t.integer  "stanford_class"
    t.string   "focus",                  :default => ""
    t.string   "degree",                 :default => ""
    t.string   "six_words",              :default => ""
    t.string   "is_alum",                :default => "0"
    t.text     "student_interview_text", :default => "== Student Interview Form ==\n\nQ: What is your favorite thing you've done so far at Stanford?\nA:\n\nQ: Why did you choose your major?\nA:\n\nQ: What are your future plans?\nA:\n"
    t.text     "alum_interview_text",    :default => "== Alum Interview Form ==\n\nQ: What's the best job you've had since graduation?\nA:\n\nQ: How did you find out about this job and why did you join?\nA:\n\nQ: What was the best part of the job?\nA:\n\nQ: What was the worst part of the job?\nA:\n\nQ: What do you wish you''d known before starting there?\nA:\n\nQ: What did you learn while there?\nA:\n\nQ: What are you most proud of during your time there?\nA:\n\nQ: Did you have any failures while there? How did you persevere?\nA:\n\nQ: What skills were most important for this job?\nA:\n\nQ: What's one story you tell about your time there?\nA:\n\nQ: If you are no longer working at this job, why did you leave?\nA:\n"
    t.string   "video_url",              :default => ""
    t.datetime "interview_date",         :default => '2010-02-11 15:55:51'
    t.text     "summary",                :default => ""
    t.string   "image_file",             :default => "blank_profile_pic.jpg"
    t.integer  "author",                 :default => 0
    t.integer  "total_views",            :default => 0
    t.integer  "total_authored",         :default => 0
    t.integer  "views",                  :default => 0
    t.integer  "likes",                  :default => 0
    t.string   "new_question",           :default => ""
    t.string   "hashed_password"
    t.datetime "date_added",             :default => '2010-02-11 15:55:51'
    t.datetime "date_modified",          :default => '2010-02-11 15:55:51'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
