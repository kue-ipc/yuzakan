# frozen_string_literal: true

module Admin
  module Controllers
    module Attrs
      class Create
        include Admin::Action

        def call(params)
          attr = AttrRepository.new.create(params[:attr])
          pam_repo = AttrMappingRepository.new
          params[:attr][:attr_mappings].each do |mapping|
            next if mapping[:name].nil? || mapping[:name].empty?

            pam_repo.create(attr_id: attr.id, **mapping)
          end
          flash[:success] = '属性を作成しました。'
          redirect_to routes.path(:attrs)
        end
      end
    end
  end
end
