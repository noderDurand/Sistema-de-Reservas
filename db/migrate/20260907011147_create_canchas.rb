class CreateCanchas < ActiveRecord::Migration[8.1]
  def change
    create_table :canchas do |t|
      t.string :nombre
      t.integer :capacidad
      t.decimal :precio

      t.timestamps
    end
  end
end
