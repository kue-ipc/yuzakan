require 'hanami/interactor'
require 'hanami/validations'

require_relative '../utils/pb_crypt'

class Decrypt
  include Hanami::Interactor

  class Validations
    include Hanami::Validations
    messages_path 'config/messages.yml'

    validations do
      required(:encrypted) { str? }
    end
  end

  expose :data

  def initialize(password: ENV.fetch('DB_SECRET'),
                 encoding: Encoding::UTF_8,
                 text: true)
    @pb_crypt = Yuzakan::Utils::PbCrypt.new(password)
    @encoding = encoding
    @text = text
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
    error!('復号化に失敗しました。')
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
