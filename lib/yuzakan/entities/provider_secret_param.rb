class ProviderSecretParam < Hanami::Entity
  include Yuzakan::Utils::Cipher

  def value
    decrypt_text(salt, encrypted_value)
  end
end
