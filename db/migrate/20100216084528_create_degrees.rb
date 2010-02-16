class CreateDegrees < ActiveRecord::Migration
  def self.up
    create_table :degrees do |t|
	t.column :user_id, :integer
	t.column :class_year, :integer, :default => 0
	t.column :degree, :string, :default => ""
	t.column :major, :string, :default => ""
      t.timestamps
    end
  end

  def self.down
    drop_table :degrees
  end
end
