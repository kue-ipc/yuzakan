Hanami::Model.migration do
  change do
    create_table :provider_templates do
      primary_key :id

      foreign_key :user_template_id,  :user_templates, on_delete: :cascade, null: false
      foreign_key :provider_id, :providers, on_delete: :cascade, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :user_template_id
      index :provider_id
      index [:user_template_id, :provider_id], unique: true
    end
  end
end
