# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :groups do
      primary_key :id

      foreign_key :affiliation_id, :affiliations, on_delete: :restrict

      column :name, String, null: false
      column :label, String, null: false, default: ""
      column :note, "text", null: false, default: ""

      column :basic, TrueClass, null: false, default: false
      column :prohibited, TrueClass, null: false, default: false

      column :deleted, TrueClass, null: false, default: false
      # null if not deleted
      column :deleted_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :affiliation_id
      index :name, unique: true
    end
  end
end
