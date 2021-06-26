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
            @user = UserRepository.new.find(params[:id])

          end
        end
      end
    end
  end
end
