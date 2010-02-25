class UpdateEditingRestrictions < ActiveRecord::Migration
  def self.up
	remove_column :users, :editing_restricted
	remove_column :users, :like_list
	add_column :users, :editing_allowed, :string, :default => "1"
  end

  def self.down
  end
end
