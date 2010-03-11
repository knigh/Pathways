class AddTempSession < ActiveRecord::Migration
  def self.up
	add_column :logs, :temp_id, :string
  end

  def self.down
  end
end
