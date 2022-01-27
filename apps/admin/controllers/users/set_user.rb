module Admin
  module Controllers
    module Users
      module SetUser
        def self.included(action)
          action.class_eval do
            before :set_user
          end
        end

        private def set_user
          @user_repository ||= UserRepository.new
          @user = @user_repository.find(params[:id])
          halt 404 if @user.nil?
        end
      end
    end
  end
end
