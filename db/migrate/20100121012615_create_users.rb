class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	t.column :name, :string
	t.column :email, :string
	t.column :email_private, :boolean
	t.column :stanford_class, :integer
	t.column :major, :string
	t.column :degree, :string
	t.column :company, :string
	t.column :title, :string
	t.column :job_start, :string
	t.column :job_end, :string
	t.column :satisfaction, :integer
	t.column :six_words, :string
	t.column :interview_text, :text
	t.column :interview_date, :datetime
	t.column :summary, :string
	
	t.column :keywords, :string
	
	t.column :author, :integer
	t.column :total_views, :integer
	t.column :total_authored, :integer
	
	t.column :image_file, :string
	
	t.column :views, :integer
	t.column :likes, :integer
	t.column :new_question, :string

	t.column :hashed_password, :string

	t.column :date_added, :datetime
	t.column :date_modified, :datetime
	
	t.column :company1, :string
	t.column :title1, :string
	t.column :job_start1, :string
	t.column :job_end1, :string
	t.column :satisfaction1, :integer
	t.column :responsibilities1, :integer
	
	t.column :company2, :string
	t.column :title2, :string
	t.column :job_start2, :string
	t.column :job_end2, :string
	t.column :satisfaction2, :integer
	t.column :responsibilities2, :integer
	
	t.column :company3, :string
	t.column :title3, :string
	t.column :job_start3, :string
	t.column :job_end3, :string
	t.column :satisfaction3, :integer
	t.column :responsibilities3, :integer
	
	t.column :company4, :string
	t.column :title4, :string
	t.column :job_start4, :string
	t.column :job_end4, :string
	t.column :satisfaction4, :integer
	t.column :responsibilities4, :integer
	
	t.column :company5, :string
	t.column :title5, :string
	t.column :job_start5, :string
	t.column :job_end5, :string
	t.column :satisfaction5, :integer
	t.column :responsibilities5, :integer
	
	t.column :company6, :string
	t.column :title6, :string
	t.column :job_start6, :string
	t.column :job_end6, :string
	t.column :satisfaction6, :integer
	t.column :responsibilities6, :integer
	
	t.column :company7, :string
	t.column :title7, :string
	t.column :job_start7, :string
	t.column :job_end7, :string
	t.column :satisfaction7, :integer
	t.column :responsibilities7, :integer
	
	t.column :company8, :string
	t.column :title8, :string
	t.column :job_start8, :string
	t.column :job_end8, :string
	t.column :satisfaction8, :integer
	t.column :responsibilities8, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
