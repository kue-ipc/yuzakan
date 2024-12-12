# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"

module Yuzakan
  module Operations
    class FindNetwork < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        messages :i18n

        validations do
          required(:ip).filled(:str?)
        end
      end

      expose :network

      def initialize(network_repository: NetworkRepository.new)
        @network_repository = network_repository
      end

      def call(params)
        ip = params[:ip]
        # unixドメインは127.0.0.1と同じとみなす
        ip = "127.0.0.1" if ip.include?("unix")

        ip_addr = IPAddr.new(ip)

        @network = @network_repository.all
          .select { |network| network.include?(ip_addr) }
          .max { |a, b| a.ipaddr.prefix <=> b.ipaddr.prefix }
      end

      private def valid?(params)
        result = Validator.new(params).validate
        if result.failure?
          Hanami.logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
          error(result.messages)
          return false
        end

        true
      end
    end
  end
end
