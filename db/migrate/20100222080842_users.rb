class Users < ActiveRecord::Migration
  def self.up
	drop_column :users, :approved
	add_column :users, :approved, :string, :default => "1"
  end

  def self.down
  end
end
