class AddSignInToViewColumnToMasters < ActiveRecord::Migration
  def self.up
	add_column :masters, :sign_in_to_view, :boolean, :default => false
  end

  def self.down
  end
end
