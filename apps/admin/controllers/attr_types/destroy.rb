module Admin
  module Controllers
    module AttrTypes
      class Destroy
        include Admin::Action

        def call(params)
          AttrTypeRepository.new.delete(params[:id])
          flash[:success] = '属性を削除しました。'
          redirect_to routes.path(:attr_types)
        end
      end
    end
  end
end
