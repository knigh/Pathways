class Users < ActiveRecord::Migration
  def self.up
	add_column :approved, :integer, :default => 0
	add_column :like_list, :string, :default => ""
  end

  def self.down
  end
end
