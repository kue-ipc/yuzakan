module Admin
  module Controllers
    module Adapters
      module Params
        class Index
          include Admin::Action
          expose :adapter

          def call(params)
            adapter_id = params[:adapter_id].to_i
            @adapter = Yuzakan::Adapters.get(adapter_id)
          end
        end
      end
    end
  end
end
