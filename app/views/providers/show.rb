# frozen_string_literal: true

module Yuzakan
  module Views
    module Providers
      class Show < Yuzakan::View
        expose :title, layout: true, decorate: false do
          i18n.t("views.provider.title")
        end
      end
    end
  end
end
