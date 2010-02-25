class AllowForOtherUniversities < ActiveRecord::Migration
  def self.up
	add_column :degrees, :school, :string, :default => "Stanford University"
  end

  def self.down
  end
end
