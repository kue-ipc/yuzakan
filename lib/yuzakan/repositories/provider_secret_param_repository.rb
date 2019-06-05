# frozen_string_literal: true

class ProviderSecretParamRepository < Hanami::Repository
  include Yuzakan::Utils::Cipher

  def create_with_encrypt(data)
    create(encrypt_value(data))
  end

  def update_with_encrypt(id, data)
    update(id, encrypt_value(data))
  end

  private def encrypt_value(data)
    if data[:value]
      salt, encrypted_value = encrypt_text(data[:value])
      data.merge(
        salt: salt,
        encrypted_value: encrypted_value
      )
    else
      data
    end
  end
end
