# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    include Deps[
      "repos.config_repo",
      "repos.network_repo",
      "repos.user_repo",
      "repos.activity_log_repo",
    ]

    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]
    # Cache
    include Hanami::Action::Cache
    cache_control :private, :no_cache
    # Others
    include Yuzakan::Actions::SecurityLevel
    include Yuzakan::Actions::CurrentAction

    include Yuzakan::Actions::Connection
    include Yuzakan::Actions::Session
    include Yuzakan::Actions::Configuration
    include Yuzakan::Actions::Authentication
    include Yuzakan::Actions::Authorization
    include Yuzakan::Actions::HandleException
    handle_exception StandardError => :handle_standard_error
  end
end
