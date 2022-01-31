require_relative '../../web/controllers/authorization'

module Admin
  module Authorization
    include Web::Authorization

    def self.included(action)
      Web::Authorization.included(action)
      action.define_singleton_method(:default_security_level) { 3 }
    end
  end
end
