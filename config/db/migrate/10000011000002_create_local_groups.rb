# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :local_groups do
      primary_key :id

      column :name, String, null: false
      column :display_name, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
    end
  end
end
