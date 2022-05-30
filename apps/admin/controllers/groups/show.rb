module Admin
  module Controllers
    module Groups
      class Show
        include Admin::Action

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def call(params)
          halt 400 unless params.valid?
        end
      end
    end
  end
end