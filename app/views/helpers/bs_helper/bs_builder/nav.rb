# auto_register: false
# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module BsHelper
        class BsBuilder
          module Nav
            def navbar_brand_link(label)
              a label, class: "navbar-brand"
            end

            def navbar_toggler_button(target, label: nil)
              button(class: "navbar-toggler", type: "button",
                data: {bs_toggle: "collapse", bs_target: "##{target}"},
                aria: {controls: target, expanded: "false", label:}) do
                span(class: "navbar-toggler-icon")
              end
            end
          end
        end
      end
    end
  end
end
