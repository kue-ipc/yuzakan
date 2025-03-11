# frozen_string_literal: true

module Admin
  module Actions
    module Connection
      include Yuzakan::Actions::Connection

      def self.included(action)
        Web::Connection.included(action)
        action.define_singleton_method(:default_security_level) { 2 }
      end
    end
  end
end
