require 'hanami/action/cache'

module Admin
  module Controllers
    module Attrs
      class Create
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          attr_repo = AttrRepository.new
          order = attr_repo.last_order&.order.to_i + 1
          attr = attr_repo.create(params[:attr].merge(order: order))
          attr_mapping_repo = AttrMappingRepository.new
          params[:attr][:attr_mappings].each do |mapping_params|
            next if mapping_params[:name].nil? || mapping_params[:name].empty?

            if mapping_params[:conversion].nil? ||
               mapping_params[:conversion].empty?
              mapping_params[:conversion] = nil
            end

            attr_mapping_repo.create(attr_id: attr.id, **mapping_params)
          end
          flash[:success] = '属性を作成しました。'
          redirect_to routes.path(:attrs)
        end
      end
    end
  end
end
