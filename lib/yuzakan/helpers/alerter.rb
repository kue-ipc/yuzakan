module Yuzakan
  module Helpers
    module Alerter
      # Bootstrapでの色
      LEVELS = {
        success: {
          color: 'success',
          icon: 'check-circle-fill',
        },
        failure: {
          color: 'warning',
          icon: 'x-octagon-fill',
        },
        fatal: {
          color: 'danger',
          icon: 'exclamation-triangle-fill',
        },
        error: {
          color: 'danger',
          icon: 'exclamation-triangle-fill',
        },
        warn: {
          color: 'warning',
          icon: 'exclamation-triangle-fill',
        },
        info: {
          color: 'info',
          icon: 'info-circle-fill',
        },
        debug: {
          color: 'secondary',
          icon: 'info-circle-fill',
        },
        unknown: {
          color: 'primary',
          icon: 'question-diamond-fill',
        },
      }.freeze

      private def levels
        Yuzakan::Helpers::Alerter::LEVELS
      end

      private def alert(level, msg)
        color = levels[level][:color]
        icon = levels[level][:icon]
        alert_class = %w[
          alert
          alert-dismissible fade show
          d-flex align-items-center
        ] + ["alert-#{color}"]
        html.div class: alert_class, role: 'alert' do
          i class: "bi bi-#{icon}"
          div class: 'ms-1' do
            span h(msg)
            button class: 'btn-close', type: 'button',
                  'data-bs-dismiss': 'alert', 'aria-label': '閉じる'
          end
        end
      end
    end
  end
end
