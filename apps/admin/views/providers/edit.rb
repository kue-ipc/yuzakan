# frozen_string_literal: true

module Admin
  module Views
    module Providers
      class Edit
        include Admin::View

        def form
          Form.new(:provider,
                   routes.provider_path(id: provider.id),
                   { provider: provider },
                   method: :patch)
        end

        def submit_label
          '更新'
        end
      end
    end
  end
end
