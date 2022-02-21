module Api
  module Controllers
    module Adapters
      module ParamTypes
        class Index
          include Api::Action

          security_level 3

          def call(params)
            adapter_id = params[:adapter_id]
            adapter = ADAPTERS_MANAGER.by_name(adapter_id)
            halt 404 unless adapter
            self.body = generate_json(adapter.param_types)
          end
        end
      end
    end
  end
end
