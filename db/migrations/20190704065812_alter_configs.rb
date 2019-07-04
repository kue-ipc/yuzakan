Hanami::Model.migration do
  change do
    alter_table :configs do
      add_column :theme, String

      add_column :password_min_size, Integer, unll: false, default: 8
      add_column :password_max_size, Integer, null: false, default: 255
      add_column :password_strength, Integer, null: false, default: 3

  end
end
