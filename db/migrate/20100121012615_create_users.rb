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
	t.column :student_interview_text, :text, :default => "== Student Interview Form ==

Q: What is your favorite thing you've done so far at Stanford?
A:

Q: Why did you choose your major?
A:

Q: What are your future plans?
A:
"
	t.column :alum_interview_text, :text, :default => "== Alum Interview Form ==

Q: What is the best job you've had since graduation?
A:

Q: How did you find out about this job and why did you join?
A:

Q: What was the best part of the job?
A:

Q: What was the worst part of the job?
A:

Q: What do you wish you had known before starting there?
A:

Q: What did you learn while there?
A:

Q: What are you most proud of during your time there?
A:

Q: Did you have any failures while there? How did you persevere?
A:

Q: What skills were most important for this job?
A:

Q: What's one story you tell about your time there?
A:

Q: If you are no longer working at this job, why did you leave?
A:
"
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
