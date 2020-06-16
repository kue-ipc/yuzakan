module Admin
  module Controllers
    module Providers
      module Params
        class Index
          include Admin::Action
          expose :provider
          expose :provider_params

          def call(params)
            @provider = ProviderRepository.new
              .find_with_params(params[:provider_id])

            adapter_class = @provider.adapter_class
            @provider_params = @provider.params.reject do |key, _value|
              adapter_param = adapter_class.param_by_name(key)
              adapter_param.nil? || adapter_param[:encrypted]
            end
          end
        end
      end
    end
  end
end
