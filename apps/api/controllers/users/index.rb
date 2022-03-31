module Api
  module Controllers
    module Users
      class Index
        include Api::Action
        include Pagy::Backend

        def initialize(user_repository: UserRepository.new, **opts)
          super
          @user_repository ||= user_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @pagy_data, @users = pagy(@user_repository)

          self.status = 200

          headers['Total-Count'] = @pagy_data.count.to_s

          self.body = generate_json(@users.to_a)
        end
      end
    end
  end
end
