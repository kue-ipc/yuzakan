# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class New
        include Admin::Action
        expose :provider

        def call(_params)
          @provider = nil
        end
      end
    end
  end
end
