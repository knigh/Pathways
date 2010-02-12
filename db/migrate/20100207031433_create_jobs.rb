class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
	t.column :user_id, :integer
	t.column :company, :string, :default => ""
	t.column :title, :string, :default => ""
	t.column :start_m, :integer, :default => 0
	t.column :start_y, :integer, :default => 0
	t.column :end_m, :integer, :default => 0
	t.column :end_y, :integer, :default => 0
	t.column :job_current, :string, :default => "0"
	t.column :satisfaction, :integer, :default => "0"
	t.column :responsibilities, :string, :default => ""
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
