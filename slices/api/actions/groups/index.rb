# frozen_string_literal: true

require_relative "../../../../lib/yuzakan/utils/pager"

module API
  module Actions
    module Groups
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
            optional(:primary_only).filled(:bool?)
            optional(:hide_prohibited).filled(:bool?)
            optional(:show_deleted).filled(:bool?)

            optional(:all).filled(:bool?)
          end
        end

        params Params

        def initialize(group_repository: GroupRepository.new,
          provider_repository: ProviderRepository.new,
          **opts)
          super
          @group_repository ||= group_repository
          @provider_repository ||= provider_repository
        end

        def handle(_req, _res)
          unless params.valid?
            halt_json 400,
              errors: [only_first_errors(params.errors)]
          end

          result =
            if params[:all]
              get_groups_all
            elsif params[:no_sync]
              get_groups_from_repository(params.to_h)
            else
              get_groups_from_provider(params.to_h)
            end

          self.status = 200
          headers.merge!(result[:headers])
          self.body = generate_json(result[:groups])
        end

        # all
        def get_groups_all
          all_groups = []
          all_groups.concat(@group_repository.all.map(&:name))
          @provider_repository.ordered_all_with_adapter_by_operation(:group_read).each do |provider|
            all_groups.concat(provider.group_list)
          end
          all_groups.uniq!
          all_groups.sort!
          {
            groups: all_groups.map { |name| {name: name} },
            headers: {"Content-Location" => routes.path(:groups, all: true)},
          }
        end

        # sync off
        def get_groups_from_repository(params)
          params = params.to_h

          order =
            if params[:order]
              name, asc_desc = params[:order].split(".", 2).map(&:intern)
              {name => asc_desc || :asc}
            else
              {name: :asc}
            end

          filter = params.slice(:query, :match)
          filter[:primary] = true if params[:primary_only]
          filter[:prohibited] = false if params[:hide_prohibited]
          filter[:deleted] = false unless params[:show_deleted]

          relation = @group_repository.ordered_filter(order: order,
            filter: filter)

          if params.key?(:page)
            pager = Yuzakan::Utils::Pager.new(relation,
                                              **params.slice(:page,
                                                :per_page)) do |link_params|
              routes.path(:groups, **params, **link_params)
            end
            {
              groups: pager.page_items,
              headers: pager.headers,
            }
          else
            {
              groups: relation.to_a,
              headers: {"Content-Location" => routes.path(:groups,
                                                          **params.except(:per_page))},
            }
          end
        end

        # sync on
        def get_groups_from_provider(params)
          params = params.to_h

          if params.key?(:order) && !params[:key].start_with?("name")
            # nameに対する順序以外は無視される。
            params = params.except(:order)
          end

          groups_providers = Hash.new { |hash, key| hash[key] = [] }
          query = ("*#{params[:query]}*" if params[:query]&.size&.positive?)

          @provider_repository.ordered_all_with_adapter_by_operation(:group_read).each do |provider|
            # プライマリグループがある場合のみ検索
            next if params[:primary_only] && !provider.has_primary_group?

            items =
              if query
                provider.group_search(query)
              else
                provider.group_list
              end
            items.each { |item| groups_providers[item] << provider.name }
          end
          all_items = groups_providers.keys

          # prohibitedなグループは隠す
          if params[:hide_prohibited]
            all_items -= @group_repository.filter(prohibited: true).map(:name)
          end

          # プロバイダーにないグループもすべて取り出す
          if params[:show_deleted]
            filter = params.slice(:query, :match)
            filter[:primary] = true if params[:primary_only]
            filter[:prohibited] = false if params[:hide_prohibited]
            all_items |= @group_repository.filter(**filter).map(:name)
          end

          all_items.sort!
          all_items.reverse! if params[:order] == "name.desc"

          pager = Yuzakan::Utils::Pager.new(all_items,
                                            **params.slice(:page,
                                              :per_page)) do |link_params|
            routes.path(:groups, **params.to_h, **link_params)
          end

          groups = get_groups(pager.page_items).map do |group|
            # プロバイダーから削除しされているが、レポジトリ―では残っている場合は同期する。
            if !group.deleted && !groups_providers.key?(group.name)
              group = get_sync_group(group.name)
            end
            {
              **convert_for_json(group),
              providers: groups_providers[group.name] || [],
            }
          end

          {
            groups: groups,
            headers: pager.headers,
          }
        end

        private def get_groups(groupnames)
          group_entities = @group_repository.all_by_name(groupnames).to_h do |group|
            [group.name, group]
          end
          groupnames.map do |groupname|
            group_entities[groupname] || get_sync_group(groupname)
          end
        end

        private def get_sync_group(groupname)
          @sync_group ||= SyncGroup.new(
            provider_repository: @provider_repository, group_repository: @group_repository)
          result = @sync_group.call({groupname: groupname})
          if result.failure?
            logger.error "[#{self.class.name}] Failed sync group: #{groupname} - #{result.errors}"
            halt_json 500, errors: result.errors
          end
          result.group
        end
      end
    end
  end
end
