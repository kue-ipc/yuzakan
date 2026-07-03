# frozen_string_literal: true

module Yuzakan
  module Views
    module User
      class Show < Yuzakan::View
        expose :title, layout: true do
          i18n.t("views.user.title")
        end
      end
    end
  end
end
