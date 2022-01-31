require_relative '../../web/controllers/connection'

module Admin
  module Connection
    include Web::Connection

    def self.included(action)
      Web::Connection.included(action)
      action.define_singleton_method(:default_security_level) { 3 }
    end
  end
end
