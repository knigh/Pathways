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

ActiveRecord::Schema.define(:version => 20100121012615) do

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "stanford_class"
    t.string   "major"
    t.string   "degree"
    t.string   "company"
    t.string   "title"
    t.string   "job_start"
    t.string   "job_end"
    t.integer  "satisfaction"
    t.string   "six_words"
    t.text     "interview_text"
    t.time     "interview_date"
    t.string   "summary"
    t.string   "keywords"
    t.integer  "author"
    t.integer  "total_views"
    t.integer  "total_authored"
    t.string   "image_file"
    t.integer  "views"
    t.integer  "likes"
    t.string   "new_question"
    t.string   "hashed_password"
    t.time     "date_added"
    t.time     "date_modified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
