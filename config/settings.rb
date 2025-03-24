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

    setting :crypt_secret, constructor: Types::String
    setting :crypt_algorithm, constructor: Types::String, default: "aes-256-cbc"
    setting :crypt_iteration, constructor: Types::Params::Integer,
      default: 10_000
    setting :crypt_salt_size, constructor: Types::Params::Integer, default: 8
    setting :crypt_kdf, constructor: Types::String, default: "pbkdf2-hmac-sha1"
  end
end
