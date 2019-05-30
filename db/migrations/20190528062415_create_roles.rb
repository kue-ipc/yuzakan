# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :roles do
      primary_key :id

      column :name, String, null: false, unique: true

      # 不変
      column :immutable, String, null: false, default: false

      # 管理権限(全て可能)
      column :admin, TrueClass, null: false, default: false

      # 設定変更
      column :config, TrueClass, null: false, default: false

      # ユーザー閲覧
      column :user_read, TrueClass, null: false, default: false

      # ユーザー登録・変更・削除
      column :user_write, TrueClass, null: false, default: false

      # グループ閲覧
      column :group_read, TrueClass, null: false, default: false

      # グループ登録・変更・削除
      column :group_write, TrueClass, null: false, default: false

      # パスワード変更
      column :password, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
