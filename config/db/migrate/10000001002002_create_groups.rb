# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :groups do
      primary_key :id

      foreign_key :affiliation_id, :affiliations, on_delete: :restrict

      column :name, String, null: false
      column :display_name, String
      column :note, "text"

      column :basic, TrueClass, null: false, default: false
      column :prohibited, TrueClass, null: false, default: false

      column :deleted, TrueClass, null: false, default: false
      column :deleted_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :affiliation_id
      index :name, unique: true
    end
  end
end
