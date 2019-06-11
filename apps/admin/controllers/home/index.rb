# frozen_string_literal: true

module Admin
  module Controllers
    module Home
      class Index
        include Admin::Action

        def call(params)
          unless ConfigRepository.new.initialized?
            redirect_to routes.path(:setup)
          end
        end
      end
    end
  end
end
