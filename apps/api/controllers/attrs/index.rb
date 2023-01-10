module Api
  module Controllers
    module Attrs
      class Index
        include Api::Action

        def initialize(attr_repository: AttrRepository.new, **opts)
          super
          @attr_repository ||= attr_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          @attrs = @attr_repository.ordered_all

          self.status = 200
          self.body = generate_json(@attrs)
        end
      end
    end
  end
end
