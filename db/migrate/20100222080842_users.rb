class Users < ActiveRecord::Migration
  def self.up
	add_column :users, :approved, :integer, :default => 0
	add_column :users, :like_list, :string, :default => ""
  end

  def self.down
  end
end
