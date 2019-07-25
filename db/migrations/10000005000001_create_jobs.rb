Hanami::Model.migration do
  change do
    create_table :jobs do
      primary_key :id

      foreign_key :owner_id, :users, on_delete: :restrict
      column :client, String

      foreign_key :user_id, :users, on_delete: :restrict

      column :action, String, null: false
      column :params, String, size: 4095
      column :status, String, null: false
      column :result, String

      column :begin_at, DateTime
      column :end_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
