class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	t.column :name, :string
	t.column :email, :string
	t.column :email_private, :string, :default => "0"
	t.column :stanford_class, :integer
	t.column :focus, :string, :default => ""
	t.column :degree, :string, :default => ""
	t.column :six_words, :string, :default => ""
	t.column :is_alum, :string, :default => "0"
	t.column :student_interview_text, :text
	t.column :alum_interview_text, :text
	t.column :video_url, :string, :default => ""
	t.column :interview_date, :datetime, :default => Time.now
	t.column :summary, :text, :default => ""
	
	t.column :image_file, :string, :default => "blank_profile_pic.jpg"
		
	t.column :author, :integer, :default => 0
	t.column :total_views, :integer, :default => 0
	t.column :total_authored, :integer, :default => 0
	t.column :views, :integer, :default => 0
	t.column :likes, :integer, :default => 0
	t.column :new_question, :string, :default => ""

	t.column :hashed_password, :string

	t.column :date_added, :datetime, :default => Time.now
	t.column :date_modified, :datetime, :default => Time.now
	
	t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
