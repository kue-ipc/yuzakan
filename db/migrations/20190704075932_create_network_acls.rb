Hanami::Model.migration do
  change do
    create_table :network_acls do
      primary_key :id

      column :order, Integer, null: false, unique: true
      column :ipaddress, String, null: false, unique: true
      column :trust, TrueClass, null: false
      column :deny, TrueClass, null: false

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
