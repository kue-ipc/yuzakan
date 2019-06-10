# frozen_string_literal: true

require 'json'

module Admin
  module Views
    module Providers
      class New
        include Admin::View

        def form
          Form.new(:provider, routes.providers_path)
        end

        def submit_label
          '作成'
        end
      end
    end
  end
end
