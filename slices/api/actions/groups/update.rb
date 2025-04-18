# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Update < API::Action
        include SetGroup

        security_level 4

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)

            optional(:name).filled(:str?, :name?, max_size?: 255)
            optional(:display_name).maybe(:str?, max_size?: 255)
            optional(:note).maybe(:str?, max_size?: 4096)

            optional(:basic).filled(:bool?)
            optional(:prohibited).filled(:bool?)

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

        def handle(_request, _response)
          if params[:name] && @group.name != params[:name]
            halt_json 422, errors: {
              name: t("errors.unchangeable", name: t("attributes.group.name")),
            }
          end

          @group = @group_repository.update(@group.id,
            params.to_h.except(:id, :name))
          self.body = group_json
        end
      end
    end
  end
end
