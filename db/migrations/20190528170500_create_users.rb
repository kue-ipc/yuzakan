# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id

      column :name, String, null: false, unique: true, index: true

      # TODO: デフォルトは1で良いのか？
      foreign_key :role_id, :roles, on_delete: :default_set, null: false, default: 1

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
