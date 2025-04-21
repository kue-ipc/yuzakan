# auto_register: false
# frozen_string_literal: true

# app/assets/js/common/alert.civet

module Yuzakan
  module Views
    module Helpers
      module AlertHelper
        include BsIconHelper

        AlertLevel = Data.define(:name, :color, :icon)

        # Bootstrapでの色とアイコン
        LEVEL_LIST = [
          # success or failure
          {name: "success", color: "success", icon: "check-circle-fill"},
          {name: "failure", color: "danger", icon: "x-circle-fill"},
          # alert level
          {name: "fatal", color: "danger", icon: "slash-circle-fill"},
          {name: "error", color: "danger", icon: "exclamation-diamond-fill"},
          {name: "warn", color: "warning", icon: "exclamation-triangle-fill"},
          {name: "info", color: "info", icon: "info-square-fill"},
          {name: "debug", color: "secondary", icon: "bug-fill"},
          {name: "unknown", color: "primary", icon: "patch-question-fill"},
          # vaild, invalid
          {name: "valid", color: "success", icon: "check"},
          {name: "invalid", color: "danger", icon: "exclamation-circle"},
        ].map { |params| AlertLevel.new(**params) }
        LEVEL_MAP = LEVEL_LIST.to_h { |level| [level.name, level] }.freeze

        def alert_level_fetch(level)
          LEVEL_MAP.fetch(level)
        end

        def alert_levels
          LEVEL_LIST
        end

        def alert_tag(level, msg)
          alert_level = alert_level_fetch(level)
          alert_class = %W[
            alert
            alert-dismissible
            fade
            show
            d-flex
            align-items-center
            alert-#{alert_level.color}
          ]
          tag.div class: alert_class, role: "alert" do
            escape_join([
              bs_icon_tag(alert_level.icon, size: 24,
                class: ["flex-shrink-0", "me-2"]),
              tag.div(tag.span(h(msg))),
              tag.button(class: "btn-close", type: "button",
                data: {"bs-dismiss": "alert"},
                aria: {label: _context.t("ui.buttons.close")}),
            ])
          end
        end

        def alert_flash
          alert_levels.to_h { |level| [level, flash[level.name]] }.compact
            .reject { |_k, v| v.empty? }
        end
      end
    end
  end
end
