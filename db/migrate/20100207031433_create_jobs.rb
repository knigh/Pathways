class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
	t.column :user_id, :integer
	t.column :company, :string
	t.column :title, :string
	t.column :start_m, :integer
	t.column :start_y, :integer
	t.column :end_m, :integer
	t.column :end_y, :integer
	t.column :job_current, :string
	t.column :satisfaction, :integer
	t.column :responsibilities, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
