require 'hanami/action/cache'

module Admin
  module Controllers
    module Attrs
      class Index
        include Admin::Action

        security_level 5

        @cache_control_directives = nil # hack
        cache_control :private, :must_revalidate, max_age: 24 * 60 * 60

        def call(params)
        end
      end
    end
  end
end
