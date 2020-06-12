# frozen_string_literal: true

module Web
  module Controllers
    module Maintenance
      class Index
        include Web::Action

        def call(params)
        end

        def configurate!
          redirect_to routes.path(:uninitialized) unless configurated?
          redirect_to routes.path(:root) unless maintenance?
        end

        def authenticate!
        end
      end
    end
  end
end
