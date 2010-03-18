class AddQuestionsTable < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
	  t.column :user_id, :integer
	  t.column :asker_id, :integer
	  t.column :question, :text
	  t.column :date_added, :datetime, :default => Time.now
	end
  end

  def self.down
	drop_table :questions
  end
end
