# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :action_logs do
      primary_key :id

      column :uuid, String, null: false
      column :client, String, null: false
      column :user, String, null: false

      column :action, String, null: false
      column :method, String, null: false
      column :path, String, null: false

      column :status, Integer

      column :created_at, Time, null: false
      column :updated_at, Time, null: false

      index :uuid
      index :client
      index :user
    end
  end
end
