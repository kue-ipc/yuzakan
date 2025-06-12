# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :attrs do
      primary_key :id

      column :name, String, null: false
      column :display_name, String, null: false, default: ""
      column :description, "text", null: false, default: ""

      column :category, String, null: false
      column :type, String, null: false

      column :order, Integer, null: false
      column :hidden, TrueClass, null: false, default: false
      column :readonly, TrueClass, null: false, default: false

      column :code, "text", null: false, default: ""

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name
      index :category
      index [:name, :category], unique: true
    end
  end
end
