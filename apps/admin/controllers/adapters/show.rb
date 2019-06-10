# frozen_string_literal: true

module Admin
  module Controllers
    module Adapters
      class Show
        include Admin::Action

        def call(params)
          self.body = 'OK'
        end
      end
    end
  end
end
