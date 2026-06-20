# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :attrs do
      primary_key :id

      column :name, String, null: false
      column :label, String, null: false, default: ""
      column :description, String, text: true, null: false, default: ""

      column :category, String, null: false
      column :type, String, null: false

      column :order, Integer, null: false
      column :hidden, TrueClass, null: false, default: false
      column :readonly, TrueClass, null: false, default: false

      column :code, String, text: true, null: false, default: ""

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :name, unique: true
      index :category
    end
  end
end
