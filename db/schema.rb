# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_07_012057) do
  create_table "canchas", force: :cascade do |t|
    t.integer "capacidad"
    t.datetime "created_at", null: false
    t.string "nombre"
    t.decimal "precio"
    t.datetime "updated_at", null: false
  end

  create_table "pagos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "fecha"
    t.string "modo"
    t.decimal "precio"
    t.integer "reserva_id", null: false
    t.datetime "updated_at", null: false
    t.index ["reserva_id"], name: "index_pagos_on_reserva_id"
  end

  create_table "reservas", force: :cascade do |t|
    t.integer "cancha_id", null: false
    t.datetime "created_at", null: false
    t.string "estado"
    t.date "fecha"
    t.integer "turno_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cancha_id"], name: "index_reservas_on_cancha_id"
    t.index ["turno_id"], name: "index_reservas_on_turno_id"
    t.index ["user_id"], name: "index_reservas_on_user_id"
  end

  create_table "turnos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.time "hora_fin"
    t.time "hora_inicio"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "pagos", "reservas"
  add_foreign_key "reservas", "canchas"
  add_foreign_key "reservas", "turnos"
  add_foreign_key "reservas", "users"
end
