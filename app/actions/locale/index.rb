# frozen_string_literal: true

module Yuzakan
  module Actions
    module Locale
      class Index < Yuzakan::Action
        security_level 0

        def handle(_request, response)
          response.format = :json
          translations = I18n.backend.translations[I18n.locale]
          response.body = {
            language: I18n.locale,
            hash: [translations.hash].pack("q<").unpack1("H16"),
            translations: translations,
          }.to_json
        end
      end
    end
  end
end
