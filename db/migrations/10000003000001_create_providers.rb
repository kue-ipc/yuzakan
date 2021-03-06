Hanami::Model.migration do
  change do
    create_table :providers do
      primary_key :id

      column :name, String, null: false
      column :display_name, String, null: false

      column :adapter_name, String, null: false
      column :order, Integer, null: false
      column :immutable, TrueClass, null: false, default: false # 不変フラグ

      column :readable, TrueClass, null: false, default: false
      column :writable, TrueClass, null: false, default: false

      column :authenticatable, TrueClass, null: false, default: false
      column :password_changeable, TrueClass, null: false, default: false
      column :individual_password, TrueClass, null: false, default: false

      column :lockable, TrueClass, null: false, default: false

      column :self_management, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :order, unique: true
      index :adapter_name
    end
  end
end
