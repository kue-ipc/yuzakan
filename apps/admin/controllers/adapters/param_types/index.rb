require 'hanami/action/cache'

module Admin
  module Controllers
    module Adapters
      module ParamTypes
        class Index
          include Admin::Action
          include Hanami::Action::Cache

          cache_control :no_store

          expose :adapter
          expose :param_types

          def call(params)
            adapter_id = params[:adapter_id]
            @adapter = ADAPTERS_MANAGER.by_name(adapter_id)
            halt 404 unless @adapter
            @param_types = @adapter.param_types
          end
        end
      end
    end
  end
end
