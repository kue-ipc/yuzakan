module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action
        include BCrypt

        def call(params)
          if params[:admin_user][:password] != params[:admin_user][:confirm_password]
            redirect_to routes.setup_path
          end

          hashed_password = Password.create(params[:admin_user][:password])

          LocalUserRepository.new.create(
            name: params[:admin_user][:name],
            hashed_password: hashed_password
          )

          ProviderRepository.new.create(
            name: 'ローカル',
            order: '0',
            adapter_id: 1,
            authenticatable: true,
            has_password: true)

          admin_role = RoleRepository.new.create(
            name: '管理者',
            admin: true
          )

          UserRepository.new.create(
            name: params[:admin_user][:name],
            role: admin_role
          )




        end
      end
    end
  end
end
