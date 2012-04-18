class CreateRoombots < ActiveRecord::Migration
  def change
    create_table :roombots do |t|
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end
