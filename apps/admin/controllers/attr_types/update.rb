module Admin
  module Controllers
    module AttrTypes
      class Update
        include Admin::Action

        def call(params)
          attr_type = AttrTypeRepository.new.update(params[:id],
                                                    params[:attr_type])
          pam_repo = ProviderAttrMappingRepository.new

          params[:attr_type][:provider_attr_mappings].each do |name, mapping|
            provider = ProviderRepository.new.find_by_name(name.to_s)
            pam = pam_repo.find_by_provider_attr_type(provider.id, attr_type.id)

            if mapping[:name].nil? && mapping[:name].empty?
              pam_repo.delete(pam.id) if pam
              next
            end
            
            if pam
              pam_repo.update(pam.id, mapping)
            else
              pam_repo.create(provider_id: provider.id, attr_type_id: attr_type.id,
                **mapping)
            end
          end
          redirect_to routes.path(:attr_types)
        end
      end
    end
  end
end
