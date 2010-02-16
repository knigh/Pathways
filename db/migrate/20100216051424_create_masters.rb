class CreateMasters < ActiveRecord::Migration
  def self.up
    create_table :masters do |t|
	t.column :logo_file, :string
	t.column :pathways_logo, :string
	t.column :informal_name, :string
	t.column :formal_name, :string
	t.column :self_description, :string
	t.column :url, :string
	t.column :alum_default_qs, :text
	t.column :student_defailt_qs, :text
      t.timestamps
    end
  end

  def self.down
    drop_table :masters
  end
end
