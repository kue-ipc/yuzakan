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

            halt 404 unless @user

            result = ResetPassword.new(user: current_user,
                                       client: remote_ip,
                                       config: current_config)
              .call(username: @user.name)

            if result.failure?
              flash[:errors] = result.errors
              flash[:failure] = 'アカウントのパスワードリセットに失敗しました。'
              redirect_to routes.path(:users, @user.name)
            end

            @password = result.password

            flash[:success] = 'アカウントのパスワードをリセットしました。'
          end
        end
      end
    end
  end
end
