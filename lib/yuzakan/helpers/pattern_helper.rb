# frozen_string_literal: true

module Yuzakan
  module Helpers
    module PatternHelper
      private def name_pattern
        '[a-z0-9_](?:[0-9a-z_-]|\.[0-9a-z_-])*'
      end

      private def domain_pattern
        '[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*'
      end
    end
  end
end
