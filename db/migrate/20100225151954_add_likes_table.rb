class AddLikesTable < ActiveRecord::Migration
  def self.up
	create_table :likes do |t|
	t.column :liked_id, :integer
	t.column :liked_by_id, :integer
    end
  end

  def self.down
	drop_table :likes
  end
end
