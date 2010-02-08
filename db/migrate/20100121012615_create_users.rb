class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	t.column :name, :string
	t.column :email, :string
	t.column :email_private, :string
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
	t.column :summary, :text
	
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
	t.column :job_start_m1, :integer
	t.column :job_start_y1, :integer
	t.column :job_end_m1, :integer
	t.column :job_end_y1, :integer
	t.column :job_current, :string
	t.column :satisfaction1, :integer
	t.column :responsibilities1, :string
	
	t.column :company2, :string
	t.column :title2, :string
	t.column :job_start_m2, :integer
	t.column :job_start_y2, :integer
	t.column :job_end_m2, :integer
	t.column :job_end_y2, :integer
	t.column :satisfaction2, :integer
	t.column :responsibilities2, :string
	
	t.column :company3, :string
	t.column :title3, :string
	t.column :job_start_m3, :integer
	t.column :job_start_y3, :integer
	t.column :job_end_m3, :integer
	t.column :job_end_y3, :integer

	t.column :satisfaction3, :integer
	t.column :responsibilities3, :string
	
	t.column :company4, :string
	t.column :title4, :string
	t.column :job_start_m4, :integer
	t.column :job_start_y4, :integer
	t.column :job_end_m4, :integer
	t.column :job_end_y4, :integer

	t.column :satisfaction4, :integer
	t.column :responsibilities4, :string
	
	t.column :company5, :string
	t.column :title5, :string
	t.column :job_start_m5, :integer
	t.column :job_start_y5, :integer
	t.column :job_end_m5, :integer
	t.column :job_end_y5, :integer

	t.column :satisfaction5, :integer
	t.column :responsibilities5, :string
	
	t.column :company6, :string
	t.column :title6, :string
	t.column :job_start_m6, :integer
	t.column :job_start_y6, :integer
	t.column :job_end_m6, :integer
	t.column :job_end_y6, :integer

	t.column :satisfaction6, :integer
	t.column :responsibilities6, :string
	
	t.column :company7, :string
	t.column :title7, :string
	t.column :job_start_m7, :integer
	t.column :job_start_y7, :integer
	t.column :job_end_m7, :integer
	t.column :job_end_y7, :integer

	t.column :satisfaction7, :integer
	t.column :responsibilities7, :string
	
	t.column :company8, :string
	t.column :title8, :string
	t.column :job_start_m8, :integer
	t.column :job_start_y8, :integer
	t.column :job_end_m8, :integer
	t.column :job_end_y8, :integer
	
	t.column :satisfaction8, :integer
	t.column :responsibilities8, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
