module Api
  module Controllers
    module Adapters
      class Show
        include Api::Action

        def call(params)
          adapter_id = params[:id]
          adapter = ADAPTERS_MANAGER.by_name(adapter_id)
          halt_json 404 unless adapter

          self.body = generate_json({
            name: adapter_id,
            label: adapter.label,
          })
        end
      end
    end
  end
end
