# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :members do
      primary_key :id

      foreign_key :user_id, :users, on_delete: :cascade, null: false
      foreign_key :group_id, :groups, on_delete: :restrict, null: false

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :user_id
      index :group_id
      index [:user_id, :group_id], unique: true
    end
  end
end
