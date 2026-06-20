# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :groups do
      primary_key :id

      foreign_key :affiliation_id, :affiliations, on_delete: :restrict

      column :name, String, null: false
      column :label, String, null: false, default: ""
      column :note, String, text: true, null: false, default: ""

      column :attrs, "jsonb", null: false, default: "{}"

      column :basic, TrueClass, null: false, default: false
      column :prohibited, TrueClass, null: false, default: false

      column :deleted_at, Time
      column :synced_at, Time

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :affiliation_id
      index :name, unique: true
    end
  end
end
