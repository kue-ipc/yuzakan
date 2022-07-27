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

          @providers = @provider_repository.ordered_all_with_adapter_by_operation(:group_read)
          providers_items = @providers.to_h { |provider| [provider.name, Set.new(provider.group_list)] }
          all_items = providers_items.values.sum(Set.new).to_a.sort

          @pager = Yuzakan::Utils::Pager.new(routes, :groups, params, all_items)

          @groups = get_groups(@pager.page_items).map do |group|
            {
              **convert_for_json(group),
              providers: providers_items.filter { |_, v| v.include?(group.name) }.keys,
            }
          end

          self.status = 200
          headers.merge!(@pager.headers)
          self.body = generate_json(@groups)
        end

        private def get_groups(groupnames)
          group_entities = @group_repository.by_groupname(groupnames).to_a.to_h { |group| [group.groupname, group] }
          groupnames.map do |groupname|
            if group_entities.key?(groupname)
              group_entities[groupname]
            else
              create_group(name)
            end
          end
        end

        private def create_group(groupname)
          @sync_group ||= SyncGroup.new(provider_repository: @provider_repository, group_repository: @group_repository)
          sync_group_result = @sync_group.call({groupname: groupname})
          halt_json 500, errors: sync_group_result.errors if sync_group_result.failure?

          sync_group_result.group
        end
      end
    end
  end
end
