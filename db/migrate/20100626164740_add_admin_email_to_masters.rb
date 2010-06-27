 class AddAdminEmailToMasters < ActiveRecord::Migration
  def self.up
	add_column :masters, :admin_email, :string, :default => ""
  end

  def self.down
  end
end
