module Web
  module Controllers
    module Gsuite
      module Password
        class Create
          include Web::Action

          expose :user
          expose :password

          def call(_params)
            gsuite_repository = ProviderRepository.new.first_gsuite_with_params
            gsuite_user = gsuite_repository.adapter.read(current_user.name)
            if gsuite_user.nil?
              flash[:failure] = 'アカウントが作成されていません。'
              redirect_to routes.path(:gsuite)
            end
  
            @password = SecureRandom.alphanumeric(16)
            @user = gsuite_repository.adapter.change_password(
              current_user.name,
              @password)
            end
        end
      end
    end
  end
end
