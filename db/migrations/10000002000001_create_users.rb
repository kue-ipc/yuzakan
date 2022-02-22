Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id

      column :name, String, null: false
      column :display_name, String, null: true
      column :email, String, null: true

      column :clearance_level, Integer, null: false, default: 1

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :email
    end
  end
end
