# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :mfa_logs do
      primary_key :id

      column :uuid, String, null: false
      column :client, String, null: false
      column :user, String, null: false

      column :type, String, null: false

      column :result, String, null: false
      column :provider, String
      column :code, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :uuid
      index :client
      index :user
      index :type
    end
  end
end
