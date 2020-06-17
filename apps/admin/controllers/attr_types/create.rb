module Admin
  module Controllers
    module AttrTypes
      class Create
        include Admin::Action

        def call(params)
          attr_type = AttrTypeRepository.new.create(params[:attr_type])
          pam_repo = ProviderAttrMappingRepository.new
          params[:attr_type][:provider_attr_mappings].each do |mapping|
            next if mapping[:name].nil? || mapping[:name].empty?

            pam_repo.create(attr_type_id: attr_type.id, **mapping)
          end
          flash[:success] = '属性を作成しました。'
          redirect_to routes.path(:attr_types)
        end
      end
    end
  end
end
