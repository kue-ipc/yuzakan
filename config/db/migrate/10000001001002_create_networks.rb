# frozen_string_literal: true

require "socket"

ROM::SQL.migration do
  change do
    create_table :networks do
      primary_key :id

      column :ip, "cidr", null: false

      column :clearance_level, Integer, null: false, default: 1
      column :trusted, TrueClass, null: false, default: false

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :ip, unique: true
    end
  end
end
