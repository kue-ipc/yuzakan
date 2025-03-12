# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"

require_relative "../utils/pb_crypt"

module Yuzakan
  module Operations
    class Encrypt < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        messages_path "config/messages.yml"

        validations do
          required(:data) { str? }
        end
      end

      expose :encrypted

      def initialize(password: ENV.fetch("DB_SECRET"), max: 0, text: false)
        @pb_crypt = Yuzakan::Utils::PbCrypt.new(password)
        @max = max
        @text = text
      end

      def call(params)
        @encrypted =
          if @text
            @pb_crypt.encrypt_text(params[:data])
          else
            @pb_crypt.encrypt(params[:data])
          end

        error!("暗号化できるサイズを超えました。") if @max.positive? && @encrypted.size > @max
      end

      private def valid?(params)
        result = Validator.new(params).validate
        if result.failure?
          logger.error "[#{self.class.name}] Validation failed: #{result.messages}"
          error(result.messages)
          return false
        end

        true
      end
    end
  end
end
