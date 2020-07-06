# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :attrs do
      primary_key :id

      column :name, String, null: false
      column :display_name, String, null: false

      column :type, String, null: false

      column :order, Integer, null: false
      column :hidden, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :order, unique: true
    end
  end
end
