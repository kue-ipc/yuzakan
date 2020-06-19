# frozen_string_literal: true

Hanami::Model.migration do
  change do
    alter_table :providers do
      add_column :individual_password, TrueClass, null: false, default: false
      add_column :self_management, TrueClass, null: false, default: false
    end
  end
end
