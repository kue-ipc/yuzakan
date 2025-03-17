# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table :users do
      add_foreign_key :group_id, :groups, on_delete: :set_null
      add_index :group_id
    end
  end

  down do
    alter_table :users do
      drop_index :group_id
      drop_foreign_key :group_id
    end
  end
end
