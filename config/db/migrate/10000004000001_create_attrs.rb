# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :attrs do
      primary_key :id

      column :name, String, null: false
      column :display_name, String
      column :description, String, size: 4096

      column :type, String, null: false

      column :order, Integer, null: false
      column :hidden, TrueClass, null: false, default: false
      column :readonly, TrueClass, null: false, default: false

      column :code, String, size: 4096

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
    end
  end
end
