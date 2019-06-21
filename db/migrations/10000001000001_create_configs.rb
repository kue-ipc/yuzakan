# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :configs do
      primary_key :id

      column :title, String, null: false
      column :maintenance, TrueClass, null: false, default: false

      column :session_timeout, Integer, null: false, default: 3600

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
