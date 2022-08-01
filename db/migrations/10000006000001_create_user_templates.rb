Hanami::Model.migration do
  change do
    create_table :user_templates do
      primary_key :id

      foreign_key :user_id,  :users,  on_delete: :cascade, null: false
      foreign_key :group_id, :groups, on_delete: :cascade, null: false

      column :name, String, null: false
      column :label, String, null: false
      column :order, Integer, null: false

      column :domain, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :order, unique: true
    end
  end
end
