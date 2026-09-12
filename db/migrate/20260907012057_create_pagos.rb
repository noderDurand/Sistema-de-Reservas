class CreatePagos < ActiveRecord::Migration[8.1]
  def change
    create_table :pagos do |t|
      t.datetime :fecha
      t.decimal :precio
      t.string :modo
      t.references :reserva, null: false, foreign_key: true

      t.timestamps
    end
  end
end
