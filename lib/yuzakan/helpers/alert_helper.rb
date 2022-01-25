module Yuzakan
  module Helpers
    module AlertHelper
      # Bootstrapでの色とアイコン
      @@levels = {  # rubocop:disable Style/ClassVars
        success: {
          color: 'success',
          icon: 'check-circle-fill',
        },
        failure: {
          color: 'danger',
          icon: 'x-circle-fill',
        },
        fatal: {
          color: 'danger',
          icon: 'alert',
        },
        error: {
          color: 'danger',
          icon: 'alert',
        },
        warn: {
          color: 'warning',
          icon: 'alert',
        },
        info: {
          color: 'info',
          icon: 'info',
        },
        debug: {
          color: 'secondary',
          icon: 'info',
        },
        unknown: {
          color: 'primary',
          icon: 'question',
        },
      }

      private def levels
        @@levels
      end

      private def alert(level, msg)
        alert_class = %w[
          alert
          alert-dismissible fade show
          d-flex align-items-center
        ] + ["alert-#{levels[level][:color]}"]
        html.div class: alert_class, role: 'alert' do
          text octicon(levels[level][:icon], size: 24,
                                             class: 'flex-shrink-0 me-2')
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
