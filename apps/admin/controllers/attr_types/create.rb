module Admin
  module Controllers
    module AttrTypes
      class Create
        include Admin::Action

        def call(params)
          attr_type = AttrTypeRepository.new.create(params[:attr_type])
          redirect_to routes.path(:attr_types)
        end
      end
    end
  end
end
