# frozen_string_literal: true

module Admin
  module Controllers
    module Adapters
      module Params
        class Index
          include Admin::Action
          expose :adapter

          def call(params)
            adapter_id = params[:adapter_id]
            @adapter = ADAPTERS.by_name(adapter_id)
            halt 404 unless @adapter
          end
        end
      end
    end
  end
end
