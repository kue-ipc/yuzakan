# frozen_string_literal: true

module Yuzakan
  class Settings < Hanami::Settings
    setting :crypt_secret, constructor: Types::String
    setting :session_secret, constructor: Types::String
    setting :session_expire, default: 24 * 60 * 60,
      constructor: Types::Params::Integer
    setting :cache_expire, default: 24 * 60 * 60,
      constructor: Types::Params::Integer
    setting :redis_url, constructor: Types::String.optional
    setting :cache_path, constructor: Types::String.optional
    setting :locale, default: "ja", constructor: Types::String
  end
end
