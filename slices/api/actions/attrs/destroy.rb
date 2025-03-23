# frozen_string_literal: true

require_relative "set_attr"

module API
  module Actions
    module Attrs
      class Destroy < API::Action
        include SetAttr

        security_level 5

        def initialize(attr_repository: AttrRepository.new, **opts)
          super
          @attr_repository ||= attr_repository
        end

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          @attr_repository.delete(@attr.id)

          self.status = 200
          self.body = generate_json(@attr, assoc: true)
        end
      end
    end
  end
end
