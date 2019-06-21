# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :roles do
      primary_key :id

      column :name, String, null: false, unique: true, index: true
      column :display_name, String, null: false, unique: true

      # 不変
      column :immutable, String, null: false, default: false

      # 管理権限(全て可能)
      column :admin, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
