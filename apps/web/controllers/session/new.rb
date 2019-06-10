# frozen_string_literal: true

module Web
  module Controllers
    module Session
      class New
        include Web::Action

        def call(params)
        end

        private

        def authenticate!; end
      end
    end
  end
end
