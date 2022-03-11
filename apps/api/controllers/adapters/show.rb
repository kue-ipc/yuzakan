module Api
  module Controllers
    module Adapters
      class Show
        include Api::Action

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          adapter_id = params[:id]
          adapter = ADAPTERS_MANAGER.by_name(adapter_id)
          halt_json 404 unless adapter

          self.body =
            if current_level >= 5
              generate_json({
                name: adapter_id,
                label: adapter.label,
                param_types: adapter.param_types,
              })
            else
              generate_json({
                name: adapter_id,
                label: adapter.label,
              })
            end
        end
      end
    end
  end
end
