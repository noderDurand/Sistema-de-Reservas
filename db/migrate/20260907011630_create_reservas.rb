class CreateReservas < ActiveRecord::Migration[8.1]
  def change
    create_table :reservas do |t|
      t.date :fecha
      t.string :estado
      t.references :cancha, null: false, foreign_key: true
      t.references :turno, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
