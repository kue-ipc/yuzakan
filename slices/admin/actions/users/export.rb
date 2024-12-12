# frozen_string_literal: true

module Admin
  module Controllers
    module Users
      class Export
        include Admin::Action

        security_level 5

        def call(params)
        end
      end
    end
  end
end
