require_relative 'bootstrap'

module Yuzakan
  module Helpers
    module Alerter
      include Bootstrap
      # Bootstrapでの色
      LEVELS = {
        success: {
          color: 'success',
          icon: 'check-circle-fill',
        },
        failure: {
          color: 'danger',
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
        alert_class = %w[
          alert
          alert-dismissible fade show
          d-flex align-items-center
        ] + ["alert-#{levels[level][:color]}"]
        html.div class: alert_class, role: 'alert' do
          text bs_icon(levels[level][:icon], size: 24, class: 'flex-shrink-0 me-2')
          div do
            span h(msg)
          end
          button class: 'btn-close', type: 'button',
          'data-bs-dismiss': 'alert', 'aria-label': '閉じる'
        end
      end
    end
  end
end
