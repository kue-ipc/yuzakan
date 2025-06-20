# frozen_string_literal: true

require_relative "../../../../lib/yuzakan/utils/pager"

module API
  module Actions
    module Users
      class Index < API::Action
        security_level 2

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            optional(:page).filled(:int?,
              included_in?: Yuzakan::Utils::Pager::PAGE_RANGE)
            optional(:per_page).filled(:int?,
              included_in?: Yuzakan::Utils::Pager::PER_PAGE_RANGE)

            optional(:order).filled(:str?, included_in?: %w[
              name
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

            optional(:no_sync).filled(:bool?)
            optional(:hide_prohibited).filled(:bool?)
            optional(:show_deleted).filled(:bool?)

            optional(:all).filled(:bool?)
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
          group_repository: GroupRepository.new,
          provider_repository: ProviderRepository.new,
          member_repository: MemberRepository.new,
          **opts)
          super
          @user_repository ||= user_repository
          @group_repository ||= group_repository
          @provider_repository ||= provider_repository
          @member_repository ||= member_repository
        end

        def handle(_request, _response)
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          result =
            if params[:all]
              get_users_all
            elsif params[:no_sync]
              get_users_from_repository(params.to_h)
            else
              get_users_from_provider(params.to_h)
            end

          self.status = 200
          headers.merge!(result[:headers])
          self.body = generate_json(result[:users])
        end

        # all
        def get_users_all
          all_users = []
          all_users.concat(@user_repository.all.map(&:name))
          @provider_repository.ordered_all_with_adapter_by_operation(:user_read).each do |provider|
            all_users.concat(provider.user_list)
          end
          all_users.uniq!
          all_users.sort!
          {
            users: all_users.map { |name| {name: name} },
            headers: {"Content-Location" => routes.path(:users, all: true)},
          }
        end

        # sync off
        def get_users_from_repository(params)
          params = params.to_h

          order =
            if params[:order]
              name, asc_desc = params[:order].split(".", 2).map(&:intern)
              {name => asc_desc || :asc}
            else
              {name: :asc}
            end

          filter = params.slice(:query, :match)
          filter[:prohibited] = false if params[:hide_prohibited]
          filter[:deleted] = false unless params[:show_deleted]

          relation = @user_repository.ordered_filter(order: order,
            filter: filter)

          if params.key?(:page)
            pager = Yuzakan::Utils::Pager.new(relation,
                                              **params.slice(:page,
                                                :per_page)) do |link_params|
              routes.path(:users, **params, **link_params)
            end
            {
              users: pager.page_items,
              headers: pager.headers,
            }
          else
            {
              users: relation.to_a,
              headers: {"Content-Location" => routes.path(:users,
                                                          **params.except(:per_page))},
            }
          end
        end

        # sync on
        def get_users_from_provider(params)
          params = params.to_h

          if params.key?(:order) && !params[:key].start_with?("name")
            # nameに対する順序以外は無視される。
            params = params.except(:order)
          end

          users_providers = Hash.new { |hash, key| hash[key] = [] }
          query = ("*#{params[:query]}*" if params[:query]&.size&.positive?)

          @provider_repository.ordered_all_with_adapter_by_operation(:user_read).each do |provider|
            items =
              if query
                provider.user_search(query)
              else
                provider.user_list
              end
            items.each { |item| users_providers[item] << provider.name }
          end
          all_items = users_providers.keys.sort

          # prohibitedなユーザーは隠す
          all_items -= @user_repository.filter(prohibited: true).map(:name) if params[:hide_prohibited]

          # プロバイダーにないユーザーもすべて取り出す
          if params[:show_deleted]
            filter = params.slice(:query, :match)
            filter[:prohibited] = false if params[:hide_prohibited]
            filter[:deleted] = false unless params[:show_deleted]
            all_items |= @user_repository.filter(**filter).map(:name)
          end

          all_items.sort!
          all_items.reverse! if params[:order] == "name.desc"

          pager = Yuzakan::Utils::Pager.new(all_items,
                                            **params.slice(:page,
                                              :per_page)) do |link_params|
            routes.path(:users, **params.to_h, **link_params)
          end

          users = get_users(pager.page_items).map do |user|
            # プロバイダーから削除しされているが、レポジトリ―では残っている場合は同期する。
            user = get_sync_user(user.name) if !user.deleted && !users_providers.key?(user.name)
            {
              **convert_for_json(user, assoc: true),
              providers: users_providers[user.name],
            }
          end

          {
            users: users,
            headers: pager.headers,
          }
        end

        private def get_users(usernames)
          user_entities = @user_repository.all_with_groups_by_name(usernames).to_h do |user|
            [user.name, user]
          end
          usernames.map do |username|
            user_entities[username] || get_sync_user(username)
          end
        end

        private def get_sync_user(username)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository,
            user_repository: @user_repository,
            group_repository: @group_repository,
            member_repository: @member_repository)
          result = @sync_user.call({username: username})
          if result.failure?
            logger.error "[#{self.class.name}] failed sync user: #{username} - #{result.errors}"
            halt_json 500, errors: result.errors
          end
          result.user
        end
      end
    end
  end
end
