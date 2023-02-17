# frozen_string_literal: true

require_relative '../../../../lib/yuzakan/utils/pager'

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
            optional(:page).filled(:int?, included_in?: Yuzakan::Utils::Pager::PAGE_RANGE)
            optional(:per_page).filled(:int?, included_in?: Yuzakan::Utils::Pager::PER_PAGE_RANGE)

            optional(:sync).filled(:bool?)

            optional(:order).filled(:str?, included_in?: %w[
              username
              display_name
              deleted_at
            ].flat_map { |name| [name, "#{name}.asc", "#{name}.desc"] })

            optional(:query).maybe(:str?, max_size?: 255)
            optional(:match).filled(:str?, included_in?: %w[
                                      extract
                                      partial
                                      forward
                                      backward
                                    ])

            optional(:hide_prohibited).filled(:bool?)
            optional(:show_deleted).filled(:bool?)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       group_repository: GroupRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
          @group_repository ||= group_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          result =
            if params[:sync]
              get_users_from_provider(params.to_h)
            else
              get_users_from_repository(params.to_h)
            end

          self.status = 200
          headers.merge!(result[:headers])
          self.body = generate_json(result[:users])
        end

        # sync off
        def get_users_from_repository(params)
          params = params.to_h.except(:sync)

          order =
            if params[:order]
              name, asc_desc = params[:order].split('.', 2).map(&:intern)
              {name => asc_desc || :asc}
            else
              {username: :asc}
            end

          query = ("%#{params[:query]}%" if params[:query]&.size&.positive?)

          filter = {}
          filter[:query] = "%#{params[:query]}%" if params[:query]&.size&.positive?
          filter[:prohibited] = false if params[:hide_prohibited]
          filter[:deleted] = false unless params[:show_deleted]

          relation = @user_repository.ordered_filter(order: order, filter: filter)

          if params.key?(:page)
            pager = Yuzakan::Utils::Pager.new(relation, **params.slice(:page, :per_page)) do |link_params|
              routes.url(:users, **params, **link_params)
            end
            {
              users: pager.page_items,
              headers: pager.headers,
            }
          else
            {
              users: relation.to_a,
              headers: {'Content-Location' => routes.url(:users, **params.except(:per_page))},
            }
          end
        end

        # sync on
        def get_users_form_provider(params)
          # syncモードでは無視される。
          params = params.to_h.except(:primary_only, :hide_prohibited, :show_deleted)

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
