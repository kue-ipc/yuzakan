# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :configs do
      primary_key :id

      column :title, String, null: false
      column :maintenance, TrueClass, null: false, default: false

      column :session_timeout, Integer, null: false, default: 3600

      column :theme, String

      column :password_min_size, Integer, unll: false, default: 8
      column :password_max_size, Integer, null: false, default: 255
      column :password_strength, Integer, null: false, default: 3

      column :remote_ip_header, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
