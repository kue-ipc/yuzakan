require 'hanami/action/cache'

module Admin
  module Controllers
    module Adapters
      module Params
        class Index
          include Admin::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :adapter

          def call(params)
            adapter_id = params[:adapter_id]
            @adapter = ADAPTERS_MANAGER.by_name(adapter_id)
            halt 404 unless @adapter
          end
        end
      end
    end
  end
end
