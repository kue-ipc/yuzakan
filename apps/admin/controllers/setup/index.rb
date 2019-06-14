# frozen_string_literal: true

module Admin
  module Controllers
    module Setup
      class Index
        include Admin::Action

        def call(params)
          redirect_to routes.path(:setup_done) if configurated?
        end

        def configurate!; end
        def authenticate!; end
      end
    end
  end
end
