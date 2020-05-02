Hanami::Model.migration do
  change do
    create_table :provider_float_params do
      primary_key :id

      foreign_key :provider_id, :providers, on_delete: :cascade, null: false

      column :name, String, null: false
      column :value, Float, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
