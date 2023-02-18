# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :groups do
      primary_key :id

      column :name, String, null: false
      column :display_name, String
      column :note, String, size: 4096

      column :primary, TrueClass, null: false, default: false
      column :prohibited, TrueClass, null: false, default: false

      column :deleted, TrueClass, null: false, default: false
      column :deleted_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
    end
  end
end
