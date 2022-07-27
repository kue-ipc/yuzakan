Hanami::Model.migration do
  change do
    create_table :local_members do
      primary_key :id

      foreign_key :local_user_id,  :users,  on_delete: :cascade, null: false
      foreign_key :local_group_id, :groups, on_delete: :cascade, null: false
      column :primary, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :local_user_id
      index :local_group_id
      index [:local_user_id, :local_group_id], unique: true
    end
  end
end
