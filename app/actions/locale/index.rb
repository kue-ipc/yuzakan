# frozen_string_literal: true

module Yuzakan
  module Actions
    module Locale
      class Index < Yuzakan::Action
        include Deps[
          "i18n",
        ]

        security_level 0

        def handle(_req, res)
          res.format = :json
          res.body = i18n.backend.translations[i18n.locale].to_json
        end
      end
    end
  end
end
