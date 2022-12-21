require_relative './set_attr'

module Api
  module Controllers
    module Attrs
      class Destroy
        include Api::Action
        include SetAttr

        security_level 5

        def initialize(attr_repository: AttrRepository.new, **opts)
          super
          @attr_repository ||= attr_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @attr_repository.delete(@attr.id)

          self.status = 200
          self.body = generate_json(@attr, assco: true)
        end
      end
    end
  end
end
