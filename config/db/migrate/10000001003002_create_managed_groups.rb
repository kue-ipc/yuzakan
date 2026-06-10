# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :managed_groups do
      primary_key :id

      foreign_key :service_id, :services, on_delete: :cascade, null: false
      foreign_key :group_id, :groups, on_delete: :restrict, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :service_id
      index :group_id
      index [:service_id, :group_id], unique: true
    end
  end
end
