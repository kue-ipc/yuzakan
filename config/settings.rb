# frozen_string_literal: true

module Yuzakan
  class Settings < Hanami::Settings
    setting :locale, constructor: Types::String, default: "ja"

    setting :session_secret, constructor: Types::String
    setting :session_expire, constructor: Types::Params::Integer,
      default: 24 * 60 * 60

    setting :cache_expire, constructor: Types::Params::Integer,
      default: 24 * 60 * 60
    setting :cache_path, constructor: Types::String.optional
    setting :redis_url, constructor: Types::String.optional

    # Deafult parameters are OWASP compliant.
    setting :crypt_secret, constructor: Types::String
    # setting :crypt_algorithm, constructor: Types::String, default: "aes-256-gcm"
    setting :crypt_algorithm, constructor: Types::String, default: "aes-256-cbc"
    setting :crypt_salt_size, constructor: Types::Params::Integer, default: 16
    setting :crypt_kdf, constructor: Types::String, default: "scrypt"
    setting :crypt_cost, constructor: Types::Params::Integer, default: 2**17
  end
end
