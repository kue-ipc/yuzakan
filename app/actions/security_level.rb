# frozen_string_literal: true

module Yuzakan
  module Actions
    module SecurityLevel
      def self.included(action_class)
        action_class.extend Dry::Core::ClassAttributes
        action_class.defines :security_level
        action_class.security_level 1
      end
    end
  end
end
