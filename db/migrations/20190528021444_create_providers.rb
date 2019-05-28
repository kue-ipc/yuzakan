Hanami::Model.migration do
  change do
    create_table :providers do
      primary_key :id

      column :name, String, null: false, unique: true
      column :adapter, String, null: false
      column :order, Integer, null: false, unique: true

      column :creatable, :boolean, null: false, default: false
      column :readable, :boolean, null: false, default: false
      column :writable, :boolean, null: false, default: false
      column :deletable, :boolean, null: false, default: false

      column :authenticatable, :boolean, null: false, default: false
      column :has_password, :boolean, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
