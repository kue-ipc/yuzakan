# frozen_string_literal: true

module Admin
  module Controllers
    module Attrs
      class Update
        include Admin::Action

        def call(params)
          attr = AttrRepository.new.update(params[:id],
                                                    params[:attr])
          pam_repo = AttrMappingRepository.new

          params[:attr][:attr_mappings].each do |mapping|
            pam = pam_repo.find_by_provider_attr(mapping[:provider_id],
                                                      attr.id)

            if mapping[:name].nil? || mapping[:name].empty?
              pam_repo.delete(pam.id) if pam
              next
            end

            if pam
              pam_repo.update(pam.id, mapping)
            else
              pam_repo.create(attr_id: attr.id, **mapping)
            end
          end
          flash[:success] = '属性を更新しました。'
          redirect_to routes.path(:attrs)
        end
      end
    end
  end
end
