# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :affiliations do
      primary_key :id

      column :name, String, null: false
      column :display_name, String
      column :note, "text"

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
