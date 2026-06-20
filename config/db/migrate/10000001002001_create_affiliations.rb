# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :affiliations do
      primary_key :id

      column :name, String, null: false
      column :label, String, null: false, default: ""
      column :note, String, text: true, null: false, default: ""

      column :attrs, "jsonb", null: false, default: "{}"

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :name, unique: true
    end
  end
end
