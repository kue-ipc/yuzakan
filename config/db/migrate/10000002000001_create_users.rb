# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do
      primary_key :id

      column :name, String, null: false
      column :display_name, String
      column :email, String
      # TODO: "text"型にすることで文字数制限をなくす。
      column :note, String, size: 4096

      column :clearance_level, Integer, null: false, default: 1

      column :prohibited, TrueClass, null: false, default: false

      column :deleted, TrueClass, null: false, default: false
      column :deleted_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :email
    end
  end
end
