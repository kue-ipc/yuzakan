# frozen_string_literal: true

module Admin
  module Controllers
    module Adapters
      class Show
        include Admin::Action

        expose :adapter

        def call(params)
          adapter_id = params[:id]
          @adapter =
            if adapter_id =~ /-A\d\z/
              Yuzakan::Adapters.get(adapter_id.to_i)
            else
              Yuzakan::Adapters.get_by_name(adapter_id)
            end
          halt 404 unless @adapter
        end
      end
    end
  end
end
