# frozen_string_literal: true

module API
  module Actions
    module Attrs
      class Index < API::Action
        def initialize(attr_repository: AttrRepository.new, **opts)
          super
          @attr_repository ||= attr_repository
        end

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          @attrs = @attr_repository.ordered_all

          self.status = 200
          self.body = generate_json(@attrs)
        end
      end
    end
  end
end
