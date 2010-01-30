class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
	t.column :name, :string
	t.column :email, :string
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
	t.column :summary, :string
	
	t.column :keywords, :string
	
	t.column :author, :integer
	t.column :total_views, :integer
	t.column :total_authored, :integer
	
	t.column :image_file, :string
	
	t.column :views, :integer
	t.column :likes, :integer
	t.column :new_question, :string

	t.column :hashed_password, :strin

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
