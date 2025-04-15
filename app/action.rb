# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"

module Yuzakan
  class Action < Hanami::Action
    include Yuzakan::Actions::Flash
    include Yuzakan::Actions::Connection
    include Yuzakan::Actions::I18n

    # HACK: HanamiのコードではDry::Vlaidation::Contractにハードコードされている
    #        ため、configを設定した任意のサブクラスでContractが作られない。
    class Params < Hanami::Action::Params
      def self.params(&block)
        @_contract = Class.new(Yuzakan::ValidationContract) {
          params(&block || -> {})
        }.new
      end
    end

    def self.params(klass = nil, &block)
      contract_class =
        if klass.nil?
          Class.new(Yuzakan::ValidationContract) { params(&block) }
        elsif klass < Hanami::Action::Params
          # Handle subclasses of Hanami::Action::Params.
          klass._contract.class
        else
          klass
        end

      config.contract_class = contract_class
    end

    def self.contract(klass = nil, &)
      contract_class = klass || Class.new(Yuzakan::ValidationContract, &)

      config.contract_class = contract_class
    end

    include Deps["logger"]

    # Cache
    include Hanami::Action::Cache
    cache_control :private, :no_cache

    # handle

    if Hanami.env?(:produciton)
      handle_exception StandardError => :handle_standard_error
    end

    private def handle_standard_error(_req, _res, exception)
      logger.error exception
      halt 500
    end
  end
end
