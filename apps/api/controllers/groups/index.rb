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
            optional(:no_sync).maybe(:bool?)
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

          group_provider_names = Hash.new { |hash, key| hash[key] = [] }
          @provider_repository.ordered_all_with_adapter_by_operation(:group_read).each do |provider|
            provider.group_list.each do |item|
              group_provider_names[item] << provider.name
            end
          end
          all_items = group_provider_names.keys.sort

          @pager = Yuzakan::Utils::Pager.new(routes, :groups, params, all_items)

          @groups = get_groups(@pager.page_items, no_sync: params[:no_sync]).map do |group|
            {
              **convert_for_json(group),
              synced_at: group.created_at,
              providers: group_provider_names[group.groupname],
            }
          end

          self.status = 200
          headers.merge!(@pager.headers)
          self.body = generate_json(@groups)
        end

        private def get_groups(groupnames, no_sync: false)
          group_entities = @group_repository.by_groupname(groupnames).to_a.to_h { |group| [group.groupname, group] }
          groupnames.map do |groupname|
            if group_entities.key?(groupname)
              group_entities[groupname]
            else
              create_group(groupname, no_sync: no_sync)
            end
          end
        end

        private def create_group(groupname, no_sync: false)
          return Group.new({groupname: groupname}) if no_sync

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
