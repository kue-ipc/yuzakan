# frozen_string_literal: true

require_relative '../../../../../lib/yuzakan/utils/pager'

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
              required(:group_id).filled(:str?, :name?, max_size?: 255)
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

            groupname = params[:group_id]
            group = @group_repository.find_by_groupname(groupname)
            halt 404 unless group

            @providers = @provider_repository.ordered_all_with_adapter_by_operation(:member_list)

            providers_items = @providers.to_h do |provider|
              list = provider.member_list(groupname)
              [provider.name, list && Set.new(list)]
            end

            all_items = providers_items.values.compact.sum(Set.new).to_a.sort

            @pager = Yuzakan::Utils::Pager.new(routes, :group_members, params, all_items)

            @members = get_members(@pager.page_items).map do |member|
              {
                **convert_for_json(member),
                providers: providers_items.filter { |_, v| v.include?(member.username) }.keys,
              }
            end

            self.status = 200
            headers.merge!(@pager.headers)
            self.body = generate_json(@members)
          end

          private def get_members(usernames)
            user_entities = @user_repository.by_username(usernames).to_a.to_h { |user| [user.username, user] }
            usernames.map do |username|
              if user_entities.key?(username)
                user_entities[username]
              else
                User.new({username: username})
              end
            end
          end
        end
      end
    end
  end
end
