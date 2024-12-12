# frozen_string_literal: true

require "digest/md5"

module Api
  module Actions
    module Adapters
      class Show < API::Action
        params IdParams

        def handle(_request, _response)
          halt_json 400, errors: [only_first_errors(params.errors)] unless params.valid?

          @adapter = ADAPTERS_MANAGER.by_name(params[:id])
          halt_json 404 unless @adapter

          fresh etag: etag

          self.body =
            if current_level >= 5
              generate_json({
                name: @adapter.name,
                label: @adapter.label,
                group: @adapter.has_group?,
                param_types: @adapter.param_types,
              })
            else
              generate_json({
                name: @adapter.name,
                label: @adapter.label,
                group: @adapter.has_group?,
              })
            end
        end

        private def etag
          Digest::MD5.hexdigest("#{@adapter.name}-#{@adapter.version}")
        end
      end
    end
  end
end
