# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :configs do
      primary_key :id

      column :title, String, null: false
      column :domain, String

      column :session_timeout, Integer, null: false, default: 3600

      column :auth_failure_waiting, Integer, null: false, default: 2
      column :auth_failure_limit, Integer, null: false, default: 5
      column :auth_failure_duration, Integer, null: false, default: 600

      column :password_min_size, Integer, null: false, default: 8
      # BCrypt's limit size is 72, over chars are ignored.
      column :password_max_size, Integer, null: false, default: 64
      column :password_min_types, Integer, null: false, default: 1
      column :password_prohibited_chars, String, null: false, default: ""

      column :password_min_score, Integer, null: false, default: 0
      column :password_extra_dict, "text[]", null: false, default: []

      column :generate_password_size, Integer, null: false, default: 24
      column :generate_password_type, String, null: false, default: "ascii"
      column :generate_password_chars, String, null: false, default: " "

      # contact
      column :contact_name, String
      column :contact_email, String
      column :contact_phone, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
