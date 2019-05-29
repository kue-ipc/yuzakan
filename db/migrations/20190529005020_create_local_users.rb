Hanami::Model.migration do
  change do
    create_table :local_users do
      primary_key :id

      column :name, String, null: false, unique: true
      column :display_name, String
      column :encrypted_password, String, null: false
      column :email, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
