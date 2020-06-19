# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :provider_attr_mappings do
      primary_key :id

      foreign_key :provider_id, :providers, on_delete: :cascade, null: false
      foreign_key :attr_type_id, :attr_types, on_delete: :cascade, null: false

      column :name, String, null: false
      column :conversion, String, null: true

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false

      index [:provider_id, :name], name: :provider_name_index, unique: true
    end
  end
end
