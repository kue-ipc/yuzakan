# frozen_string_literal: true

module Admin
  module Views
    module Config
      class New < Admin::View
        def form
          Form.new(
            :config,
            routes.path(:config),
            {config: config, admin_user: admin_user},
            method: :post)
        end
      end
    end
  end
end
