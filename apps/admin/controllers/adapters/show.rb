# frozen_string_literal: true

module Admin
  module Controllers
    module Adapters
      class Show
        include Admin::Action

        expose :adapter

        def call(params)
          adapter_id = params[:id]
          @adapter = ADAPTERS.by_name(adapter_id)
          halt 404 unless @adapter
        end
      end
    end
  end
end
