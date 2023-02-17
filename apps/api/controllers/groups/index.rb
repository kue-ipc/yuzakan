# frozen_string_literal: true

require_relative '../../../../lib/yuzakan/utils/pager'

module Api
  module Controllers
    module Groups
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
              groupname
              display_name
              deleted_at
            ].flat_map { |name| [name, "#{name}.asc", "#{name}.desc"] })

            optional(:query).maybe(:str?, max_size?: 255)

            optional(:primary_only).filled(:bool?)
            optional(:hide_prohibited).filled(:bool?)
            optional(:show_deleted).filled(:bool?)
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

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          result =
            if params[:sync]
              get_groups_from_provider(params.to_h)
            else
              get_groups_from_repository(params.to_h)
            end

          self.status = 200
          headers.merge!(result[:headers])
          self.body = generate_json(result[:groups])
        end

        # sync off
        def get_groups_from_repository(params)
          params = params.to_h.except(:sync)

          order =
            if params[:order]
              name, asc_desc = params[:order].split('.', 2).map(&:intern)
              {name => asc_desc || :asc}
            else
              {groupname: :asc}
            end

          query = ("%#{params[:query]}%" if params[:query]&.size&.positive?)

          filter = {}
          filter[:query] = "%#{params[:query]}%" if params[:query]&.size&.positive?
          filter[:primary] = true if params[:primary_only]
          filter[:prohibited] = false if params[:hide_prohibited]
          filter[:deleted] = false unless params[:show_deleted]

          relation = @group_repository.ordered_filter(order: order, filter: filter)

          if params.key?(:page)
            pager = Yuzakan::Utils::Pager.new(relation, **params.slice(:page, :per_page)) do |link_params|
              routes.url(:groups, **params, **link_params)
            end
            {
              groups: pager.page_items,
              headers: pager.headers,
            }
          else
            {
              groups: relation.to_a,
              headers: {'Content-Location' => routes.url(:groups, **params.except(:per_page))},
            }
          end
        end

        # sync on
        def get_groups_from_provider(params)
          # syncモードでは無視される。
          params = params.to_h.except(:primary_only, :hide_prohibited, :show_deleted)

          if params.key?(:order) && !params[:key].start_with?('groupname')
            # groupnameに対する順序以外は無視される。
            params = params.except(:order)
          end

          groups_providers = Hash.new { |hash, key| hash[key] = [] }
          query = ("*#{params[:query]}*" if params[:query]&.size&.positive?)

          @provider_repository.ordered_all_with_adapter_by_operation(:group_read).each do |provider|
            items =
              if query
                provider.group_search(query)
              else
                provider.group_list
              end
            items.each { |item| groups_providers[item] << provider.name }
          end

          all_groupnames = groups_providers.keys
          all_groupnames.sort!
          all_groupnames.reverse! if params[:order] == 'groupname.desc'

          pager = Yuzakan::Utils::Pager.new(all_groupnames, **params.slice(:page, :per_page)) do |link_params|
            routes.path(:groups, **params.to_h, **link_params)
          end

          groups = get_groups(pager.page_items).map do |group|
            {
              **convert_for_json(group),
              providers: groups_providers[group.groupname],
            }
          end

          {
            groups: groups,
            headers: pager.headers,
          }
        end

        private def get_groups(groupnames)
          group_entities = @group_repository.all_by_groupname(groupnames).to_h { |group| [group.groupname, group] }
          groupnames.map do |groupname|
            group_entities[groupname] || create_group(groupname)
          end
        end

        private def create_group(groupname)
          @sync_group ||= SyncGroup.new(provider_repository: @provider_repository, group_repository: @group_repository)
          result = @sync_group.call({groupname: groupname})
          if result.failure?
            Hanami.logger.error "[#{self.class.name}] Failed sync group: #{groupname} - #{result.errors}"
            halt_json 500, errors: result.errors
          end
          result.group
        end
      end
    end
  end
end
