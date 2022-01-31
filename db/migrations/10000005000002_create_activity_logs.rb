Hanami::Model.migration do
  change do
    create_table :activity_logs do
      primary_key :id

      column :username, String, null: true
      column :client, String, null: false

      column :action, String, null: false
      column :method, String, null: false
      column :path, String, null: false
      column :status, Integer

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :username
      index :client
    end
  end
end
