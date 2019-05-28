Hanami::Model.migration do
  change do
    create_table :providers do
      primary_key :id

      column :name, String, null: false, unique: true
      column :adapter, String, null: false
      column :primary, :boolean, null: false, default: false

      column :authenticatable, :boolean, null: false, default: false
      column :creatable, :boolean, null: false, default: false
      column :delteable, :boolean, null: false, default: false
      column :passward_changable, :boolean, null: false, default: false
      column :readable, :boolean, null: false, default: false
      column :writable, :boolean, null: false, default: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
