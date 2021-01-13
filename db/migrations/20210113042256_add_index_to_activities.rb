Hanami::Model.migration do
  change do
    alter_table :activities do
      add_index :type
      add_index :target
      add_index :action
      add_index :result
    end
  end
end
