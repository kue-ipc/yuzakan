# frozen_string_literal: true

module Admin
  module Controllers
    module Attrs
      class Destroy
        include Admin::Action

        def call(params)
          AttrRepository.new.delete(params[:id])
          flash[:success] = '属性を削除しました。'
          redirect_to routes.path(:attrs)
        end
      end
    end
  end
end
