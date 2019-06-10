module Admin
  module Controllers
    module Adapters
      module Params
        class Index
          include Admin::Action
          expose :adapter

          def call(params)
            adapter_id = params[:adapter_id]
            @adapter =
              if adapter_id =~ /-A\d\z/
                Yuzakan::Adapters.get(adapter_id.to_i)
              else
                Yuzakan::Adapters.get_by_name(adapter_id)
              end
          end
        end
      end
    end
  end
end
