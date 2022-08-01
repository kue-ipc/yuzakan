Hanami::Model.migration do
  change do
    create_table :attr_templates do
      primary_key :id

      foreign_key :user_template_id, :user_templates, on_delete: :cascade, null: false
      foreign_key :attr_id, :attrs, on_delete: :cascade, null: false

      column :code, String, size: 4096, null: true
      column :required, TrueClass, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :user_template_id
      index :attr_id
      index [:user_template_id, :attr_id], unique: true
    end
  end
end
