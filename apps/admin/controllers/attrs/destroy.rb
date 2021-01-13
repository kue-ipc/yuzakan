require 'hanami/action/cache'

module Admin
  module Controllers
    module Attrs
      class Destroy
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        def call(params)
          AttrRepository.new.delete(params[:id])
          flash[:success] = '属性を削除しました。'
          redirect_to routes.path(:attrs)
        end
      end
    end
  end
end
