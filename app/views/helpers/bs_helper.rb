# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        def bs_navbar_brand(label)
          link_to label, "#", class: "navbar-brand"
        end

        def bs_navbar_toggler(target)
          tag.button(class: "navbar-toggler", type: "button",
            data: {bs_toggle: "collapse", bs_target: "##{target}"},
            aria: {controls: target, expanded: "false",
                   label: _context.t("view.buttons.toggle_navigation"),}) do
            tag.span(class: "navbar-toggler-icon")
          end
        end
      end
    end
  end
end
