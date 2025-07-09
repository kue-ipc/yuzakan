# frozen_string_literal: true

module Yuzakan
  module Views
    module Services
      class Show < Yuzakan::View
        expose :title, layout: true, decorate: false do
          i18n.t("views.service.title")
        end
      end
    end
  end
end
