# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :providers do
      primary_key :id

      column :name, String, null: false
      column :label, String, null: false, default: ""
      column :description, "text", null: false, default: ""

      column :order, Integer, null: false

      column :adapter, String, null: false
      column :params, "jsonb", null: false

      column :readable, TrueClass, null: false, default: false
      column :writable, TrueClass, null: false, default: false

      column :authenticatable, TrueClass, null: false, default: false
      column :password_changeable, TrueClass, null: false, default: false
      column :lockable, TrueClass, null: false, default: false

      column :group, TrueClass, null: false, default: false

      column :individual_password, TrueClass, null: false, default: false
      column :self_management, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
    end
  end
end
