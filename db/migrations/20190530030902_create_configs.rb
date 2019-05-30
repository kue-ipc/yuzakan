Hanami::Model.migration do
  change do
    create_table :configs do
      primary_key :id

      column :initialized, TrueClass, null: false

      foreign_key :default_role_id, :roles, null: false

      column :auto_create_user, TrueClass, null: false, default: true

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
