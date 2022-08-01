Hanami::Model.migration do
  change do
    create_table :member_templates do
      primary_key :id

      foreign_key :user_template_id,  :user_templates, on_delete: :cascade, null: false
      foreign_key :group_id, :groups, on_delete: :cascade, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :user_template_id
      index :group_id
      index [:user_template_id, :group_id], unique: true
    end
  end
end
