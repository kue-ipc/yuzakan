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

          query = params[:query]
          query = nil if query&.empty?
          page = params[:page] || 1
          per_page = params[:per_mage] || 20

          @providers = @provider_repository.ordered_all_with_adapter_by_operation(:group_read)

          providers_list = @providers.to_h { |provider| [provider.name, Set.new(provider.group_list)] }

          all_list = providers_list.values.sum(Set.new).to_a.sort
          total_count = all_list.size
          item_offset = (page - 1) * per_page

          page_list = all_list[item_offset, per_page] || []

          groups_data = @group_repository.by_name(page_list).to_a.to_h { |group| [group.name, group] }

          @groups = page_list.map do |name|
            groups_data[name] || create_group(name)
          end

          first_page = 1
          last_page = ((total_count / per_page) + 1)
          links = []
          links << "<#{routes.groups_url(page: first_page, query: query)}>; rel=\"first\""
          links << "<#{routes.groups_url(page: page - 1, query: query)}>; rel=\"prev\"" if page != first_page
          links << "<#{routes.groups_url(page: page + 1, query: query)}>; rel=\"next\"" if page != last_page
          links << "<#{routes.groups_url(page: last_page, query: query)}>; rel=\"last\""
          data = @groups.map do |group|
            {
              **convert_for_json(group),
              providers: providers_list.filter { |_, v| v.include?(group.name) }.keys,
            }
          end

          self.status = 200
          headers['Total-Count'] = total_count.to_s
          headers['Link'] = links.join(', ')
          headers['Content-Range'] =
            if total_count.positive?
              "items #{item_offset}-#{item_offset + data.size - 1}/#{total_count}"
            else
              'items 0-0/0'
            end
          self.body = generate_json(data)
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
