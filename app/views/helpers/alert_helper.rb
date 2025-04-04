# frozen_string_literal: true

module Yuzakan
  module Views
    module Helpers
      module AlertHelper
        # Bootstrapでの色とアイコン
        LEVELS = {
          success: {
            color: "success",
            icon: "check-circle-fill",
          },
          failure: {
            color: "danger",
            icon: "x-circle-fill",
          },
          fatal: {
            color: "danger",
            icon: "slash-circle-fill",
          },
          error: {
            color: "danger",
            icon: "exclamation-octagon-fill",
          },
          warn: {
            color: "warning",
            icon: "exclamation-triangle-fill",
          },
          info: {
            color: "info",
            icon: "info-square-fill",
          },
          debug: {
            color: "secondary",
            icon: "bug-fill",
          },
          unknown: {
            color: "primary",
            icon: "question-diamond-fill",
          },
        }.freeze

        def levels
          LEVELS
        end

        def alert(level, msg)
          alert_class = %w[
            alert
            alert-dismissible fade show
            d-flex align-items-center
          ] + ["alert-#{levels[level][:color]}"]
          tag.div class: alert_class, role: "alert" do
            [
              bs_icon(levels[level][:icon], size: 24,
                class: "flex-shrink-0 me-2"),
              tag.div(tag.span(h(msg))),
              tag.button(class: "btn-close", type: "button",
                data: {"bs-dismiss": "alert"},
                aria: {label: _context.t("view.buttons.close")}),
            ].join.html_safe
          end
        end
      end
    end
  end
end
