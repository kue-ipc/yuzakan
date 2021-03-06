Hanami::Model.migration do
  change do
    create_table :local_users do
      primary_key :id

      column :name, String, null: false
      column :hashed_password, String, null: false
      column :display_name, String
      column :email, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
    end
  end
end
