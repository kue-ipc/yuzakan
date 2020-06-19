# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :attr_types do
      primary_key :id

      column :name, String, null: false
      column :display_name, String, null: false

      column :type, String, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :display_name, unique: true
    end
  end
end
