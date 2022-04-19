module Api
  module Controllers
    module Users
      class Show
        include Api::Action

        security_level 2

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new, **opts)
          super
          @user_repository ||= user_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [params.errors] unless params.valid?

          username = params[:id]
          user = user_repository.find_by_name(username)

          read_user = ReadUser.new(provider_repository: @provider_repository)
          result = read_user.call(username: username)

          halt_json 500, erros: result.errors if result.failure?

          halt_json 404 if user.nil? && result.userdatas.empty?

          self.body = generate_json({
            **convert_for_json(user),
            userdatas: result.userdatas,
          })
        end
      end
    end
  end
end
