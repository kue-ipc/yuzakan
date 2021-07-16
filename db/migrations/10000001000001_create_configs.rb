Hanami::Model.migration do
  change do
    create_table :configs do
      primary_key :id

      column :title, String, null: false
      column :maintenance, TrueClass, null: false, default: false

      column :session_timeout, Integer, null: false, default: 3600

      column :password_min_size, Integer, unll: false, default: 8
      # BCrypt's limit size is 72, over chars are ignored.
      column :password_max_size, Integer, null: false, default: 64
      column :password_min_types, Integer, null: false, default: 1
      column :password_min_score, Integer, null: false, default: 3
      column :password_unusable_chars, String, null: false, default: ''
      column :password_extra_dict, String, size: 4096, null: false, default: ''

      # at most 30 neworks
      column :admin_networks, String, size: 1024, null: false, default: ''
      column :user_networks, String, size: 1024, null: false, default: ''

      # contact
      column :contact_name, String
      column :contact_email, String
      column :contact_phone, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
