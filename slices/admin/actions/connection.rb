# frozen_string_literal: true

require_relative "../../web/controllers/connection"

module Admin
  module Connection
    include Web::Connection

    def self.included(action)
      Web::Connection.included(action)
      action.define_singleton_method(:default_security_level) { 2 }
    end
  end
end
