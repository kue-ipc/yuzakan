# frozen_string_literal: true

ROM::SQL.migration do
  up do
    alter_table :local_users do
      add_foreign_key :local_group_id, :local_groups,
        on_delete: :set_null, null: true
      add_index :local_group_id
    end
  end

  down do
    alter_table :local_users do
      drop_index :local_group_id
      drop_foreign_key :local_group_id
    end
  end
end
