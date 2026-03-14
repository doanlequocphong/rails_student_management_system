class CreateClassrooms < ActiveRecord::Migration[7.1]
  def change
    create_table :classrooms do |t|
      t.string :name
      t.text :description
      t.string :academic_year

      t.timestamps
    end
  end
end
