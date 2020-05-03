# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :configs do
      primary_key :id

      column :title, String, null: false
      column :maintenance, TrueClass, null: false, default: false

      column :session_timeout, Integer, null: false, default: 3600

      column :password_min_size, Integer, unll: false, default: 8
      column :password_max_size, Integer, null: false, default: 255
      column :password_min_types, Integer, null: false, default: 1
      column :password_min_score, Integer, null: false, default: 3
      column :password_unusable_chars, String
      column :password_extra_dict, String, size: 4095

      column :remote_ip_header, String
      column :trusted_reverse_proxies, String, size: 4095

      column :admin_networks, String, size: 4095

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
