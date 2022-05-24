Hanami::Model.migration do
  change do
    alter_table :attrs do
      add_column :code, String, size: 1024, default: nil
    end
  end
end
