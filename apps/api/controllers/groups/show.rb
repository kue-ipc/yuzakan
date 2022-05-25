module Api
  module Controllers
    module Groups
      class Show
        include Api::Action

        security_level 2

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new,
                       group_repository: GroupRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
          @group_repository ||= group_repository
        end

        def call(params)
          halt_json 400, errors: [params.errors] unless params.valid?

          groupname = params[:id]

          sync_group = SyncGroup.new(provider_repository: @provider_repository, group_repository: @group_repository)
          result = sync_group.call({groupname: groupname})
          halt_json 500, erros: result.errors if result.failure?

          halt_json 404 unless result.group

          self.body = generate_json({
            **convert_for_json(result.group),
            groupdata: result.groupdata,
            groupdata_list: result.groupdata_list,
          })
        end
      end
    end
  end
end
