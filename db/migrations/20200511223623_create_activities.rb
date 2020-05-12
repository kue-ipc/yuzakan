Hanami::Model.migration do
  change do
    create_table :activities do
      primary_key :id

      foreign_key :user_id, :users, on_delete: :set_null, null: true
      column :ip, String

      column :type, String, index: true, null: false
      column :target, String, index: true
      column :action, String, index: true, null: false
      column :params, String, size: 65535
      column :result, String, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
