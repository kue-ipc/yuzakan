Hanami::Model.migration do
  change do
    alter_table :configs do
      add_column :contact_name, String
      add_column :contact_email, String
      add_column :contact_phone, String
    end
  end
end
