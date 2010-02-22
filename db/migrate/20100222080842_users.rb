class Users < ActiveRecord::Migration
  def self.up
	change_column :users, :approved, :string, :default => "1"
  end

  def self.down
  end
end
