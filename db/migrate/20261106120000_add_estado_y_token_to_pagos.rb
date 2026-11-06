# Pago simulado con QR: el pago nace "pendiente" con un token único (va dentro
# del QR) y pasa a "aprobado" cuando se escanea.
class AddEstadoYTokenToPagos < ActiveRecord::Migration[8.1]
  class MigrationPago < ApplicationRecord
    self.table_name = "pagos"
  end

  def up
    add_column :pagos, :estado, :string, null: false, default: "pendiente"
    add_column :pagos, :token, :string

    # Los pagos que ya existían se cargaron a mano y ya estaban cobrados.
    MigrationPago.reset_column_information
    MigrationPago.find_each do |pago|
      pago.update_columns(estado: "aprobado", token: SecureRandom.base58(24))
    end

    add_index :pagos, :token, unique: true
    # Una reserva tiene un solo pago (has_one): que la base lo garantice.
    remove_index :pagos, :reserva_id
    add_index :pagos, :reserva_id, unique: true

    # Sin revisión del admin, la unicidad de horario la tiene que garantizar
    # la base: dos requests simultáneos pasarían la validación de Rails.
    add_index :reservas, [ :cancha_id, :turno_id, :fecha ],
              unique: true, where: "estado != 'cancelada'",
              name: "index_reservas_horario_unico_activo"
  end

  def down
    remove_index :reservas, name: "index_reservas_horario_unico_activo"
    remove_index :pagos, :reserva_id
    add_index :pagos, :reserva_id
    remove_index :pagos, :token
    remove_column :pagos, :token
    remove_column :pagos, :estado
  end
end
