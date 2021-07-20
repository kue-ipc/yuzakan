module Admin
  module Controllers
    module Users
      module Password
        class Create
          include Admin::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :user
          expose :password

          def call(params)
            user_id = params[:user_id]
            if user_id =~ /\A\d+\z/
              @user = UserRepository.new.find(user_id)
            else
              @user = UserRepository.new.by_name(user_id).one
              @user ||= UserRepository.new.sync(user_id)
            end

            pp @user

            # provider = ProviderRepository.new
            #   .operational_all_with_adapter(:change_password)

            # result = ResetPassword.new(user: @user,
            #                            client: remote_ip,
            #                            config: current_config,
            #                            providers: providers)
            #   .call(params.get(:user_password))

            # if result.failure?
            #   flash[:errors] = result.errors
            #   flash[:failure] = 'アカウントのパスワードリセットに失敗しました。'
            #   redirect_to routes.path(:google)
            # end

            # @password = result.password
            @password = 'dummy'

            flash[:success] = 'アカウントのパスワードをリセットしました。'
          end
        end
      end
    end
  end
end
