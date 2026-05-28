# frozen_string_literal: true

module API
  module Views
    module Adapters
      class Index < API::View
        include Deps["adapter_repo"]

        expose :adapters do
          adapter_repo.all
        end
      end
    end
  end
end
