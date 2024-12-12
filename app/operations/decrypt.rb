# frozen_string_literal: true

require "hanami/interactor"
require "hanami/validations"

require_relative "../utils/pb_crypt"

module Yuzakan
  module Operations
    class Decrypt < Yuzakan::Operation
      include Hanami::Interactor

      class Validator
        include Hanami::Validations
        messages_path "config/messages.yml"

        validations do
          required(:encrypted) { str? }
        end
      end

      expose :data

      def initialize(password: ENV.fetch("DB_SECRET"), text: false, encoding: Encoding::UTF_8)
        @pb_crypt = Yuzakan::Utils::PbCrypt.new(password)
        @text = text
        @encoding = encoding
      end

      def call(params)
        @data =
          if @text
            @pb_crypt.decrypt_text(params[:encrypted], encoding: @encoding)
          else
            @pb_crypt.decrypt(params[:encrypted])
          end
      rescue OpenSSL::Cipher::CipherError
        @data = nil
        error!("復号化に失敗しました。")
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
