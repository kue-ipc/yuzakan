# frozen_string_literal: true

module Yuzakan
  module Views
    module About
      class Index < Yuzakan::View
        expose :title, layout: true, decorate: false do
          i18n.t("views.about.title")
        end
      end
    end
  end
end
