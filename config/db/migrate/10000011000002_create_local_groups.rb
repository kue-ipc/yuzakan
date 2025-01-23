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

    create_table :local_groups do
      primary_key :id

      column :name, String, null: false
      column :display_name, String

      column :attrs, attrs_type, null: false

      index :name, unique: true
    end
  end
end
