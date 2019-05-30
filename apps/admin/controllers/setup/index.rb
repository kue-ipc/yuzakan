# frozen_string_literal: true

module Admin
  module Controllers
    module Setup
      class Index
        include Admin::Action

        def call(params)
          if ConfigRepository.new.initialized?
            redirect_to routes.path(:setup_done)
          end
        end
      end
    end
  end
end
