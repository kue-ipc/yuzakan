Hanami::Model.migration do
  change do
    create_table :admin_networks do
      primary_key :id

      column :address, String, null: false, unique: true
      column :family, Integer, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
