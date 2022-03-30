require 'digest/md5'

module Api
  module Controllers
    module Adapters
      class Show
        include Api::Action

        @cache_control_directives = nil # hack
        cache_control :private

        def call(params)
          id_validation = IdValidations.new(params).validate
          halt_json 400, errors: [id_validation.messages] if id_validation.failure?

          @adapter = ADAPTERS_MANAGER.by_name(params[:id])
          halt_json 404 unless @adapter

          fresh etag: etag

          self.body =
            if current_level >= 5
              generate_json({
                name: @adapter.name,
                label: @adapter.label,
                param_types: @adapter.param_types,
              })
            else
              generate_json({
                name: @adapter.name,
                label: @adapter.label,
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
