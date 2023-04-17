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
                       group_repository: GroupRepository.new,
                       member_repository: MemberRepository.new,
                       **opts)
          super
          @config_repository ||= config_repository
          @network_repository ||= network_repository
          @provider_repository ||= provider_repository
          @user_repository ||= user_repository
          @group_repository ||= group_repository
          @member_repository ||= member_repository
        end

        def call(params)
          flash[:errors] ||= []

          if configurated?
            flash[:errors] << I18n.t('errors.already_initialized')
            redirect_to Web.routes.path(:root)
          end

          unless params.valid?
            flash[:errors] << params.errors
            flash[:failure] = '設定に失敗しました。'
            self.body = Admin::Views::Config::New.render(exposures)
            return
          end

          begin
            setup_network
            setup_local_provider
            setup_admin(params[:config][:admin_user].to_h)
            setup_config(params[:config].except(:admin_user).to_h)
          rescue => e
            flash[:errors] << e.message
            flash[:failure] = '設定に失敗しました。'
            self.body = Admin::Views::Config::New.render(exposures)
            return
          end

          flash[:success] = '初期設定が完了しました。' \
                            '管理者でログインしてください。'
        end

        def configurate!
        end

        private def setup_network
          return if @network_repository.count.positive?

          @network_repository.transaction do
            [
              '127.0.0.0/8',
              '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16',
              '::1',
              'fc00::/7',
            ].each do |address|
              @network_repository.create_or_update_by_address(address, {clearance_level: 5, trusted: true})
            end
            ['0.0.0.0/0', '::/0'].each do |address|
              @network_repository.create_or_update_by_address(address, {clearance_level: 1, trusted: false})
            end
          end
        end

        private def setup_local_provider
          return if @provider_repository.find_by_name('local')

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
        end

        private def setup_admin(admin_user_params)
          admin_user = get_user(admin_user_params[:username])

          unless admin_user
            create_result = proider_create_user.call({
              **admin_user_params.slice(:username, :password),
              providers: ['local'],
              display_name: 'ローカル管理者',
            })
            if create_result.failure?
              flash[:errors].concat(create_result.errors)
              return false
            end

            admin_user = get_user(admin_user_params[:username])
          end

          @user_repository.update(admin_user.id, clearance_level: 5) if admin_user.clearance_level < 5
        end

        private def setup_config(config_params)
          return if @config_repository.current

          @config_repository.current_create({**config_params, maintenace: false})
        end

        private def sync_user
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository,
                                      user_repository: @user_repository,
                                      group_repository: @group_repository,
                                      member_repository: @member_repository)
        end

        private def proider_create_user
          @proider_create_user = ProviderCreateUser.new(provider_repository: @provider_repository)
        end

        private def get_user(username)
          sync_result = sync_user.call({username: username})
          if sync_result.failure?
            sync_result[:errors].concat(sync_result.errors)
            raise '同期処理に失敗しました'
          end
          sync_result.user
        end
      end
    end
  end
end
