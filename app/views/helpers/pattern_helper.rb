# auto_register: false
# frozen_string_literal: true

# TODO: Typeと統合すべき

module Yuzakan
  module Views
    module Helpers
      module PatternHelper
        def name_pattern
          '[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*'
        end

        def domain_pattern
          '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
        end
      end
    end
  end
end
