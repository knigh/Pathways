class AddToLogs < ActiveRecord::Migration
  def self.up
	add_column :logs, :user_id, :integer
	add_column :logs, :ab_assignment, :string
	add_column :logs, :url_visited, :string
	add_column :logs, :time_visited, :string
  end

  def self.down
  end
end
