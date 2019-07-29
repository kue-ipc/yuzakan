# frozen_string_literal: true

module Web
  module Views
    module Home
      class Index
        include Web::View
        layout false

        def title
          'ユーザー管理システム'
        end

        # Bootstrapでの色
        def level_colors
          {
            fatal: 'danger',
            error: 'danger',
            warn: 'warning',
            info: 'info',
            debug: 'secondary',
            unknown: 'primary',
            failure: 'danger',
            success: 'success',
          }
        end
      end
    end
  end
end
