Hanami::Model.migration do
  change do
    create_table :user_templates do
      primary_key :id

      foreign_key :primary_group_id, :groups, on_delete: :set_null

      column :name, String, null: false
      column :label, String, null: false
      column :order, Integer, null: false

      column :domain, String

      column :description, String, size: 4096

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :name, unique: true
      index :order, unique: true
    end
  end
end
