# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Parts
      class MenuItem < Yuzakan::Views::Part
        def path
          context.routes.path(value.name)
        end

        def link_tag(**)
          title = context.t("title", scope: ["views", value.name])
          helpers.link_to(title, path, **)
        end
      end
    end
  end
end
