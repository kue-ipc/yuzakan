module Api
  module Controllers
    module Users
      module SetUser
        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        def self.included(_action)
          aciton.class_eval do
            params Params
            before :set_user
          end
        end

        private def set_user
          halt_json 400, errors: [params.errors] unless params.valid?

          username = params[:id]

          sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = sync_user.call({username: username})
          halt_json 500, erros: result.errors if result.failure?
          @user = result.user

          halt_json 404 if @user.nil?
        end
      end
    end
  end
end
