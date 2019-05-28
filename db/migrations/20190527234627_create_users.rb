Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id

      column :name, String, null: false, unique: true
      column :presence, :boolean, null: false
      column :reserved, :boolean, null: false, default: false
      column :admin, :boolean, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
