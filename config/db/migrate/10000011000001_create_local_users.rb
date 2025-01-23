# frozen_string_literal: true

ROM::SQL.migration do
  change do
    attrs_type =
      case database_type
      in :postgres
        "jsonb"
      else
        "text"
      end

    create_table :local_users do
      primary_key :id

      column :name, String, null: false
      column :hashed_password, String
      column :display_name, String
      column :email, String

      column :locked, TrueClass, null: false, default: false

      column :attrs, attrs_type, null: false

      index :name, unique: true
    end
  end
end
