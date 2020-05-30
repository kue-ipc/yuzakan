# frozen_string_letral: true

require 'hanami/interactor'
require 'hanami/validations'

require_relative '../utils/pb_crypt'

class Decrypt
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:data) { str? }
    end
  end

  def initialize(password: ENV.fetch('DB_SECRET'),
                 encoding: Encoding::UTF_8)
    @pb_crypt = Yuzakan::Utils::PbCrypt.new(password)
    @encoding = encoding
  end

  def call(params)
    @pb_crypt.decrypt_text(params[:data], encoding: @encoding)
  end

  private def valid?(params)
    validation = Validations.new(params).validate
    if validation.failure?
      error(validation.messages)
      return false
    end

    true
  end
end
