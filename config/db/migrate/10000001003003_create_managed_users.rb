# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :managed_users do
      primary_key :id

      foreign_key :service_id, :services, on_delete: :cascade, null: false
      foreign_key :user_id, :users, on_delete: :restrict, null: false

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :service_id
      index :user_id
      index [:service_id, :user_id], unique: true
    end
  end
end
