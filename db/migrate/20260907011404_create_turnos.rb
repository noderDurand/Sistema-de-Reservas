class CreateTurnos < ActiveRecord::Migration[8.1]
  def change
    create_table :turnos do |t|
      t.time :hora_inicio
      t.time :hora_fin

      t.timestamps
    end
  end
end
