Hanami::Model.migration do
  change do
    create_table :groups do
      primary_key :id

      column :groupname, String, null: false
      column :display_name, String
      column :note, String, size: 4096

      column :primary, TrueClass, null: false, default: false
      column :reserved, TrueClass, null: false, default: false
      column :obsoleted, TrueClass, null: false, default: false

      column :deleted, TrueClass, null: false, default: false
      column :deleted_at, DateTime

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index :groupname, unique: true
    end
  end
end
