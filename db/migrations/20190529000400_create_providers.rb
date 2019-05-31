# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :providers do
      primary_key :id

      column :name, String, null: false, unique: true

      # 不変
      column :immutable, String, null: false, default: false

      column :order, Integer, null: false, unique: true
      column :adapter_id, Integer, null: true

      column :creatable, TrueClass, null: false, default: false
      column :readable, TrueClass, null: false, default: false
      column :writable, TrueClass, null: false, default: false
      column :deletable, TrueClass, null: false, default: false

      column :authenticatable, TrueClass, null: false, default: false
      column :has_password, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
