Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id

      foreign_key :primary_group_id, :groups, on_delete: :set_null, null: true
 
      column :username, String, null: false
      column :display_name, String, null: true
      column :email, String, null: true

      column :clearance_level, Integer, null: false, default: 1

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :username, unique: true
      index :email
    end
  end
end
