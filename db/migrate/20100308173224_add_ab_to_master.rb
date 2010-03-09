class AddAbToMaster < ActiveRecord::Migration
  def self.up
	add_column :masters, :ab_last_assigned, :integer, :default => 1
	remove_column :users, :total_authored
  end

  def self.down
  end
end
