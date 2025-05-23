# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :local_users do
      primary_key :id

      foreign_key :local_group_id, :local_groups, on_delete: :set_null

      column :name, String, null: false
      column :hashed_password, String
      column :display_name, String
      column :email, String

      column :locked, TrueClass, null: false, default: false

      column :attrs, "jsonb", null: false

      index :local_group_id
      index :name, unique: true
    end
  end
end
