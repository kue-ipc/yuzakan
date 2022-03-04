module Api
  module Controllers
    module Adapters
      class Show
        include Api::Action

        class Params < Hanami::Action::Params
          messages :i18n

          params do
            required(:id).filled(:str?, max_size?: 255)
          end
        end

        params Params

        def call(params)
          halt_json 400, errors: params.errors unless params.valid?

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
