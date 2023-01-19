# frozen_string_literal: true

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
            optional(:sync).maybe(:str?, included_in?: ['default', 'forced', 'no'])
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       group_repository: GroupRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          query = (params[:query] if params[:query]&.size&.positive?)

          sync =
            if params[:sync]&.size&.positive?
              params[:sync].intern
            else
              :default
            end

          user_provider_names = Hash.new { |hash, key| hash[key] = [] }
          @provider_repository.ordered_all_with_adapter_by_operation(:user_read).each do |provider|
            items = if query then provider.user_search("*#{query}*") else provider.user_list end
            items.each do |item|
              user_provider_names[item] << provider.name
            end
          end
          all_items = user_provider_names.keys.sort

          @pager = Yuzakan::Utils::Pager.new(routes, :users, params, all_items)

          @users = get_users(@pager.page_items, sync: sync).map do |user|
            {
              **convert_for_json(user),
              synced_at: user.created_at,
              provider_names: user_provider_names[user.username],
            }
          end

          self.status = 200
          headers.merge!(@pager.headers)
          self.body = generate_json(@users)
        end

        private def get_users(usernames, sync: :default)
          case sync
          when :default
            # DBに存在しない場合のみ同期する
            user_entities = get_user_entities(usernames)
            usernames.map do |username|
              user_entities[username] || get_sync_user(username)
            end
          when :forced
            # DBに存在しても同期する
            usernames.map do |username|
              get_sync_user(username)
            end
          when :no
            # DBに存在しない場合でも同期しない
            user_entities = get_user_entities(usernames)
            usernames.map do |username|
              user_entities[username] || User.new({username: username})
            end
          else
            raise "Unknown sync: #{sync}"
          end
        end

        private def get_user_entities(usernames)
          @user_repository.by_username(usernames).to_a.to_h { |user| [user.username, user] }
        end

        private def get_sync_user(username)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository,
                                      user_repository: @user_repository,
                                      group_repository: @group_repository)
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
