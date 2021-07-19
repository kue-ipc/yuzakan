module Admin
  module Controllers
    module Users
      module Password
        class Create
          include Admin::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :user

          def call(params)
            user_id = params[:user_id]
            if user_id =~ /\A\d+\z/
              @user = UserRepository.new.find(user_id)
            else
              @user = UserRepository.new.by_name(user_id).one
              @user ||= UserRepository.new.sync(user_id)
            end

            pp @user
          end
        end
      end
    end
  end
end
