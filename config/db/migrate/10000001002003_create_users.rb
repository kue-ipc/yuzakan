# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :users do
      primary_key :id

      foreign_key :affiliation_id, :affiliations, on_delete: :restrict
      foreign_key :group_id, :groups, on_delete: :restrict

      column :name, String, null: false
      column :label, String, null: false, default: ""
      column :email, String, null: false, default: ""
      column :note, String, text: true, null: false, default: ""

      column :attrs, "jsonb", null: false, default: "{}"
      column :locked_count, Integer, null: false, default: 0

      column :clearance_level, Integer, null: false, default: 1
      column :prohibited, TrueClass, null: false, default: false

      column :deleted_at, Time
      column :synced_at, Time

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :affiliation_id
      index :group_id
      index :name, unique: true
      index :email
    end
  end
end
