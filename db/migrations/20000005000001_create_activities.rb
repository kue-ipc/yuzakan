Hanami::Model.migration do
  change do
    create_table :activities do
      primary_key :id

      foreign_key :user_id, :users, on_delete: :set_null, null: true
      column :client, String, null: false

      column :type, String, null: false
      column :target, String
      column :action, String, null: false
      column :params, String, size: 4096
      column :result, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :user_id
      index :client
      index :type
      index :target
      index :action
      index :result
    end
  end
end
