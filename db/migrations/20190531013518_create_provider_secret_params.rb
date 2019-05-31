Hanami::Model.migration do
  change do
    create_table :provider_secret_params do
      primary_key :id

      foreign_key :provider_id, :providers, on_delete: :cascade, null: false

      column :name, String, null: false
      column :salt, String, null: false, size: 12 # 8 バイトのBASE64
      column :encrypted_value, String, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
