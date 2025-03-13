# frozen_string_literal: true

module Yuzakan
  module Actions
    module Locale
      class Index < Yuzakan::Action
        security_level 0

        def handle(_req, res)
          res.format = :json
          res.body = I18n.backend.translations[I18n.locale].to_json
        end
      end
    end
  end
end
