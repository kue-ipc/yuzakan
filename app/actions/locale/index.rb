# frozen_string_literal: true

module Yuzakan
  module Actions
    module Locale
      class Index < Yuzakan::Action
        security_level 0

        def handle(_request, response)
          response.format = :json
          response.body = I18n.backend.translations[I18n.locale].to_json
        end
      end
    end
  end
end
