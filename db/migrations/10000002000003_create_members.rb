Hanami::Model.migration do
  change do
    create_table :members do
      primary_key :id

      foreign_key :user_id,  :users,  on_delete: :cascade, null: false
      foreign_key :group_id, :groups, on_delete: :cascade, null: false
      column :primary, TrueClass, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :user_id
      index :group_id
      index [:user_id, :group_id], name: :user_group_index, unique: true
    end
  end
end
