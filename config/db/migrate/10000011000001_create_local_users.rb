# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :local_users do
      primary_key :id

      column :name, String, null: false
      column :hashed_password, String
      column :display_name, String
      column :email, String

      column :locked, TrueClass, null: false, default: false

      column :attrs, "jsonb", null: false

      index :name, unique: true
    end
  end
end
