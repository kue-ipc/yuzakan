# frozen_string_literal: true

Hanami::Model.migration do
  change do
    create_table :users do
      primary_key :id

      foreign_key :role_id, :roles, on_delete: :set_null, null: true,
                                    index: true

      column :name, String, null: false, unique: true, index: true

      column :display_name, String, null: true
      column :email, String, null: true, index: true

      column :created_at, DateTime, null: false
      column :updated_at, DateTime, null: false
    end
  end
end
