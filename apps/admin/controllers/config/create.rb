# frozen_string_literal: true

module Admin
  module Controllers
    module Config
      class Create
        include Admin::Action

        security_level 0

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:config).schema do
              required(:title).filled(:str?, max_size?: 255)
              required(:domain).maybe(:str?, max_size?: 255)
              required(:admin_user).schema do
                required(:username).filled(:str?, :name?, max_size?: 255)
                required(:password).filled(:str?, min_size?: 8, max_size?: 255).confirmation
              end
            end
          end
        end

        params Params

        expose :config
        expose :admin_user

        def initialize(config_repository: ConfigRepository.new,
                       network_repository: NetworkRepository.new,
                       provider_repository: ProviderRepository.new,
                       user_repository: UserRepository.new,
                       **opts)
          super
          @config_repository ||= config_repository
          @network_repository ||= network_repository
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
        end

        def call(params)
          flash[:errors] ||= []

          if configurated?
            flash[:errors] << I18n.t('errors.already_initialized')
            redirect_to Web.routes.path(:root)
          end

          @config = params[:config]&.except(:admin_user) || {}
          @admin_user = params[:config]&.[](:admin_user) || {}

          unless params.valid?
            flash[:errors] << params.errors
            self.body = Admin::Views::Config::New.render(exposures)
            return
          end

          setup_network &&
            setup_local_provider &&
            setup_admin(@admin_user) &&
            setup_config(@config)

          unless flash[:errors].empty?
            self.body = Admin::Views::Config::New.render(exposures)
            return
          end

          flash[:success] = '初期セットアップが完了しました。' \
                            '管理者でログインしてください。'
        end

        def configurate!
        end

        private def setup_network
          return true if @network_repository.count.positive?

          ['127.0.0.0/8',
           '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16',
           '::1',
           'fc00::/7',].each do |address|
            @network_repository.create_or_update_by_address(address, {clearance_level: 5, trusted: true})
          end
          ['0.0.0.0/0', '::/0'].each do |address|
            @network_repository.create_or_update_by_address(address, {clearance_level: 1, trusted: false})
          end

          true
        end

        private def setup_local_provider
          return true if @provider_repository.find_by_name('local')

          @provider_repository.create({
            name: 'local',
            display_name: 'ローカル',
            order: '0',
            adapter_name: 'local',
            readable: true,
            writable: true,
            authenticatable: true,
            password_changeable: true,
            lockable: true,
          })

          true
        end

        private def setup_admin(admin_user)
          return true if @user_repository.find_by_username(admin_user[:username])

          create_user = CreateUser.new(provider_repository: @provider_repository)
          result = create_user.call({
            **admin_user,
            providers: ['local'],
            display_name: 'ローカル管理者',
          })
          if result.failure?
            flash[:errors].concat(result.errors)
            return false
          end

          sync_user = SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = sync_user.call(admin_user.slice(:username))
          if result.failure?
            flash[:errors].concat(result.errors)
            return false
          end

          admin_user = result.user
          @user_repository.update(admin_user.id, clearance_level: 5)

          true
        end

        private def setup_config(config)
          return true if @config_repository.current

          @config_repository.current_create({**config, maintenace: false})
          true
        end
      end
    end
  end
end
