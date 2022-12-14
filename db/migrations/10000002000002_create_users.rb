Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id

      foreign_key :primary_group_id, :groups, on_delete: :set_null
 
      column :username, String, null: false
      column :display_name, String
      column :email, String

      column :reserved, TrueClass, null: false, dafault: false

      column :deleted, TrueClass, null: false, default: false
      column :deleted_at, DateTime

      column :clearance_level, Integer, null: false, default: 1

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :username, unique: true
      index :email
    end
  end
end
