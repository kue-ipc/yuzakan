# frozen_string_literal: true

module Admin
  module Controllers
    module Setup
      class Create
        include Admin::Action

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

        def setup_initial_data(username, password)
          local_provider = ProviderRepository.new.create(
            name: 'ローカル',
            immutable: true,
            order: '0',
            adapter_id: 1,
            readable: true,
            writable: true,
            authenticatable: true,
            password_changeable: true,
            lockable: true
          )
          local_provider_adapter = local_provider.adapter.new({})
          local_provider_adapter.create(
            username,
            display_name: 'ローカル管理者'
          )
          local_provider_adapter.change_password(username, password)

          role_repo = RoleRepository.new
          none_role = role_repo.create(
            name: '権限なし',
            immutable: true,
            admin: false
          )

          admin_role = role_repo.create(
            name: '管理者',
            immutable: true,
            admin: true
          )

          UserRepository.new.create(
            name: username,
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
