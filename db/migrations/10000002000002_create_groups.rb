# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :groups do
      primary_key :id

      column :name, String, null: false
      column :display_name, String, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
    end
  end
end
