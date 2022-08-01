Hanami::Model.migration do
  change do
    create_table :attr_mappings do
      primary_key :id

      foreign_key :provider_id, :providers, on_delete: :cascade, null: false
      foreign_key :attr_id, :attrs, on_delete: :cascade, null: false

      column :name, String, null: false
      column :conversion, String

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :provider_id
      index :attr_id
      index [:provider_id, :attr_id], unique: true
    end
  end
end
