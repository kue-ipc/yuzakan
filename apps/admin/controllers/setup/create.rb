# frozen_string_literal: true

module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action
        include BCrypt

        def call(params)
          if ConfigRepository.new.initialized?
            redirect_to routes.path(:setup_done)
          end

          if params[:admin_user][:password] !=
             params[:admin_user][:confirm_password]
            redirect_to routes.setup_path
          end

          setup_initial_data(params[:admin_user][:name],
                             params[:admin_user][:password])
        end

        def setup_initial_data(name, password)
          hashed_password = Password.create(password)

          lu_repo = LocalUserRepository.new.create(
            name: name,
            hashed_password: hashed_password
          )

          ProviderRepository.new.create(
            name: 'ローカル',
            immutable: true,
            order: '0',
            adapter_id: 1,
            authenticatable: true,
            has_password: true
          )

          role_repo = RoleRepository.new
          none_role = role_repo.create(
            name: '権限なし',
            immutable: true,
            admin: true
          )

          admin_role = role_repo.create(
            name: '管理者',
            immutable: true,
            admin: true
          )

          UserRepository.new.create(
            name: name,
            role_id: admin_role.id
          )

          ConfigRepository.new.create(
            initialized: true,
            default_role_id: none_role.id
          )
        end
      end
    end
  end
end
