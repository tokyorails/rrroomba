class AddRoombotIdToSchedules < ActiveRecord::Migration
  def change
    add_column :schedules, :roombot_id, :integer, :after => :id
  end
end
