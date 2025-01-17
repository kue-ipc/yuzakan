# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]
    # Cache
    include Hanami::Action::Cache
    cache_control :private, :no_cache
    # Csutmise
    include Yuzakan::Actions::Connection
    include Yuzakan::Actions::Configuration
    include Yuzakan::Actions::Authentication
    include Yuzakan::Actions::Authorization
    include Yuzakan::Actions::HandleException
    handle_exception StandardError => :handle_standard_error
  end
end
