# frozen_string_literal: true

require "socket"

ROM::SQL.migration do
  change do
    create_table :networks do
      primary_key :id

      # TODO: PostgreSQLでは"cidr"型にすることで事前検索を可能にしたい。
      column :address, String, null: false

      column :clearance_level, Integer, null: false, default: 1
      column :trusted, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :address, unique: true
    end
  end
end
