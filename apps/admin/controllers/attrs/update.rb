require 'hanami/action/cache'

module Admin
  module Controllers
    module Attrs
      class Update
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          attr = AttrRepository.new.update(params[:id],
                                           params[:attr])
          attr_mapping_repo = AttrMappingRepository.new

          params[:attr][:attr_mappings].each do |mapping_params|
            attr_mapping = attr_mapping_repo
              .find_by_provider_attr(mapping_params[:provider_id], attr.id)

            if mapping_params[:name].nil? || mapping_params[:name].empty?
              attr_mapping_repo.delete(attr_mapping.id) if attr_mapping
              next
            end

            if mapping_params[:conversion].nil? ||
               mapping_params[:conversion].empty?
              mapping_params[:conversion] = nil
            end

            if attr_mapping
              attr_mapping_repo.update(attr_mapping.id, mapping_params)
            else
              attr_mapping_repo.create(attr_id: attr.id, **mapping_params)
            end
          end
          flash[:success] = '属性を更新しました。'
          redirect_to routes.path(:attrs)
        end
      end
    end
  end
end
