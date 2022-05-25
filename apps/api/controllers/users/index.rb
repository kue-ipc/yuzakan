require 'set'

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
          end
        end

        params Params

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          query = params[:query]
          query = nil if query&.empty?
          page = params[:page] || 1
          per_page = params[:per_mage] || 50

          @providers = @provider_repository.ordered_all_with_adapter_by_operation(:read)

          providers_list =
            if query
              @providers.to_h { |provider| [provider.name, Set.new(provider.search("*#{query}*"))] }
            else
              @providers.to_h { |provider| [provider.name, Set.new(provider.list)] }
            end

          all_list = providers_list.values.sum(Set.new).to_a.sort
          total_count = all_list.size
          item_offset = (page - 1) * per_page

          page_list = all_list[item_offset, per_page] || []

          users_data = @user_repository.by_name(page_list).to_a.to_h { |user| [user.name, user] }

          @users = page_list.map do |name|
            users_data[name] || create_user(name)
          end

          first_page = 1
          last_page = ((total_count / per_page) + 1)
          links = []
          links << "<#{routes.users_url(page: first_page, query: query)}>; rel=\"first\""
          links << "<#{routes.users_url(page: page - 1, query: query)}>; rel=\"prev\"" if page != first_page
          links << "<#{routes.users_url(page: page + 1, query: query)}>; rel=\"next\"" if page != last_page
          links << "<#{routes.users_url(page: last_page, query: query)}>; rel=\"last\""
          data = @users.map do |user|
            {
              **convert_for_json(user),
              providers: providers_list.filter { |_, v| v.include?(user.name) }.keys,
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

        private def create_user(username)
          @sync_user ||= SyncUser.new(provider_repository: @provider_repository, user_repository: @user_repository)
          sync_user_result = @sync_user.call({username: username})
          if sync_user_result.failure?
            Hanami.logger.error "failed sync user: #{username} - #{sync_user_result.errors}"
            halt_json 500, errors: sync_user_result.errors
          end
          sync_user_result.user
        end
      end
    end
  end
end
