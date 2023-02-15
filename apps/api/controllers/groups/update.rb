module Api
  module Controllers
    module Groups
      class Update
        include Api::Action
        include SetGroup

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:sync).filled(:bool?)

            optional(:groupname).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:note).maybe(:str?, max_size?: 4096)

            optional(:primary).filled(:bool?)
            optional(:obsoleted).filled(:bool?)

            optional(:deleted).filled(:bool?)
            optional(:deleted_at).maybe(:date_time?)
          end
        end

        params Params

        def initialize(group_repository: GroupRepository.new,
                       **opts)
          super
          @group_repository ||= group_repository
        end

        def call(params)
          if @group.groupname != params[:groupname]
            halt_json 422, errors: {
              groupname: I18n.t('errors.unchangeabl', name: I18n.t('attributes.group.groupname')),
            }
          end

          @group = @group_repository.update(@group.id, params.to_h.except(:id, :sync, :groupname))
          self.body = group_json
        end
      end
    end
  end
end
