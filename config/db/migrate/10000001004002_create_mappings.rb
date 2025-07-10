# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :mappings do
      primary_key :id

      foreign_key :attr_id, :attrs, on_delete: :cascade, null: false

      foreign_key :service_id, :services, on_delete: :cascade, null: false
      column :key, String, null: false

      column :type, String, null: false
      column :params, "jsonb", null: true

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :service_id
      index :attr_id
      index [:service_id, :attr_id], unique: true
    end
  end
end
