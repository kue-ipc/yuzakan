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
            optional(:page).filled(:int?, gteq?: 1, lteq?: 10000)
            optional(:per_page).filled(:int?, gteq?: 10, lteq?: 100)

            optional(:sync).filled(:bool?)

            optional(:order).filled(:str?, included_in?: %w[
              groupname
              display_name
              deleted_at
              created_at
              updated_at
            ].flat_map { |name| [name, "#{name}.asc", "#{name}.desc"] })

            optional(:query).maybe(:str?, max_size?: 255)

            optional(:primary_only).filled(:bool?)
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

          if params[:sync]
            get_groups_from_provider(params)
          else
            get_groups_from_repository(params)
          end

          groups =
            if @groups_providers
              @groups.map do |group|
                {**convert_for_json(group), providers: @groups_providers[group.groupname]}
              end
            else
              @groups
            end

          self.status = 200
          headers.merge!(@pager.headers)
          self.body = generate_json(groups)
        end

        # order
        def get_groups_from_repository(params)
          order =
            if params[:order]
              name, asc_desc = params[:order].split('.', 2).map(&:intern)
              {name => asc_desc || :asc}
            else
              {groupname: :asc}
            end

          filter = {}
          filter[:query] = params[:query] if params[:query] && !params[:query].empty?
          filter[:primary] = true if params[:primary_only]
          filter[:deleted] = false unless params[:show_deleted]

          relation = @group_repository.ordered_filter(order: order, filter: filter)
          @pager = Yuzakan::Utils::Pager.new(relation, **params.to_h.slice(:page, :per_page)) do |link_params|
            routes.url(:groups, **params.to_h, **link_params)
          end
          @groups = @pager.page_items
        end

        def get_groups_from_provider(params)
          @groups_providers = Hash.new { |hash, key| hash[key] = [] }
          @provider_repository.ordered_all_with_adapter_by_operation(:group_read).each do |provider|
            provider.group_list.each do |item|
              @groups_providers[item] << provider.name
            end
          end

          all_groupnames = @groups_providers.keys
          all_groupnames.sort!
          all_groupnames.reverse! if params[:order] == 'groupname.desc'

          @pager = Yuzakan::Utils::Pager.new(all_groupnames, **params.to_h.slice(:page, :per_page)) do |link_params|
            routes.url(:groups, **params.to_h, **link_params)
          end
          @groups = get_groups(@pager.page_items)
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
