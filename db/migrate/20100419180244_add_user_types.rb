class AddUserTypes < ActiveRecord::Migration
  def self.up
	rename_column :users, :is_alum, :user_type 
  end

  def self.down
	rename_column :users, :user_Type, :is_alum
  end
end
