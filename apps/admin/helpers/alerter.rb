# frozen_string_literal: true

module Web
  module Helpers
    module Alerter
      # Bootstrapでの色
      private def level_colors
        @level_colors ||= {
          success: 'success',
          failure: 'warning',
          fatal: 'danger',
          error: 'danger',
          warn: 'warning',
          info: 'info',
          debug: 'secondary',
          unknown: 'primary',
        }
      end
    end
  end
end
