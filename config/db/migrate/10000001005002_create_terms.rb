# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :terms do
      primary_key :id

      foreign_key :dictionary_id, :dictionaries, on_delete: :cascade,
        null: false

      column :term, String, null: false
      column :description, "text", null: false

      index :dictionary_id
      index :term
    end
  end
end
