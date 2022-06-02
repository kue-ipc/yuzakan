module Api
  module Controllers
    module Groups
      module Members
        class Index
          include Api::Action

          security_level 2

          class Params < Hanami::Action::Params
            predicates NamePredicates
            messages :i18n

            params do
              required(:id).filled(:str?, :name?, max_size?: 255)
              optional(:page).filled(:int?, gteq?: 1, lteq?: 10000)
              optional(:per_page).filled(:int?, gteq?: 10, lteq?: 100)
            end
          end

          params Params

          def initialize(provider_repository: ProviderRepository.new,
                         group_repository: GroupRepository.new,
                         user_repository: UserRepository.new,
                         **opts)
            super
            @provider_repository ||= provider_repository
            @group_repository ||= group_repository
            @user_repository ||= user_repository
          end

          def call(params)
            halt_json 400, errors: [params.errors] unless params.valid?

            query = params[:query]
            query = nil if query&.empty?
            page = params[:page] || 1
            per_page = params[:per_mage] || 20

            groupname = params[:id]
            group = @group_repository.find_by_name(groupname)
            halt 404 unless group

            @providers = @provider_repository.ordered_all_with_adapter_by_operation(:member_list)

            providers_list = @providers.to_h do |provider|
              list = provider.member_list(groupname)
              if list
                [provider.name, Set.new(provider.member_list(groupname))]
              else
                [proviedr.name, nil]
              end
            end

            all_list = providers_list.values.compact.sum(Set.new).to_a.sort
            total_count = all_list.size
            item_offset = (page - 1) * per_page

            page_list = all_list[item_offset, per_page] || []

            first_page = 1
            last_page = ((total_count / per_page) + 1)
            links = []
            links << "<#{routes.group_members_url(groupname, page: first_page, per_apge: per_page)}>; rel=\"first\""
            if page != first_page
              links << "<#{routes.group_members_url(groupname, page: page - 1,
                                                               per_apge: per_page)}>; rel=\"prev\""
            end
            if page != last_page
              links << "<#{routes.group_members_url(groupname, page: page + 1,
                                                               per_apge: per_page)}>; rel=\"next\""
            end
            links << "<#{routes.group_members_url(groupname, page: last_page, query: query)}>; rel=\"last\""

            data = page_list.map do |name|
              {
                usnername: name,
                providers: providers_list.filter { |_, v| v.include?(name) }.keys,
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
        end
      end
    end
  end
end
