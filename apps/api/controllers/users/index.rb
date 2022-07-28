require 'set'

module Api
  module Controllers
    module Users
      class Index
        include Api::Action

        security_level 2

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            optional(:page).filled(:int?, gteq?: 1, lteq?: 10000)
            optional(:per_page).filled(:int?, gteq?: 10, lteq?: 100)
            optional(:query).maybe(:str?, max_size?: 255)
            optional(:no_sync).maybe(:bool?)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          query = params[:query]
          query = nil if query&.empty?

          @providers = @provider_repository.ordered_all_with_adapter_by_operation(:user_read)
          providers_items = @providers.to_h do |provider|
            items = if query then provider.user_search("*#{query}*") else provider.user_list end
            [provider.name, Set.new(items)]
          end
          all_items = providers_items.values.sum(Set.new).to_a.sort

          @pager = Yuzakan::Utils::Pager.new(routes, :users, params, all_items)

          @users = get_users(@pager.page_items, no_sync: params[:no_sync]).map do |user|
            {
              **convert_for_json(user),
              providers: providers_items.filter { |_, v| v.include?(user.username) }.keys,
            }
          end

          self.status = 200
          headers.merge!(@pager.headers)
          self.body = generate_json(@users)
        end

        private def get_users(usernames, no_sync: false)
          user_entities = @user_repository.by_username(usernames).to_a.to_h { |user| [user.username, user] }
          usernames.map do |username|
            if user_entities.key?(username)
              user_entities[username]
            else
              create_user(username, no_sync: no_sync)
            end
          end
        end

        private def create_user(username, no_sync: false)
          return User.new({username: username}) if no_sync

          @sync_user ||= SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          result = @sync_user.call({username: username})
          if result.failure?
            Hanami.logger.error "failed sync user: #{username} - #{result.errors}"
            halt_json 500, errors: result.errors
          end
          result.user
        end
      end
    end
  end
end
