module Admin
  module Controllers
    module Providers
      class Create
        include Admin::Action

        def call(params)
          adapter_id = params[:provider][:adapter_id].to_i
          adapter = Yuzakan::Adapters.get(adapter_id)

          repo = ProviderRepository.new
          provider = repo.create(
            name: params[:provider][:name],
            order: repo.last_order.order + 1,
            adapter_id: adapter_id,
            authenticatable: true,
            has_password: true
          )

          string_param_repo = ProviderStringParamRepository.new
          secret_param_repo = ProviderSecretParamRepository.new
          integer_param_repo = ProviderIntegerParamRepository.new
          boolean_param_repo = ProviderBooleanParamRepository.new

          params[:provider][:params].each do |name, value|
            data = {
              provider_id: provider.id,
              name: name.to_s,
            }
            case adapter.param_type(name)
            when :string
              data[:value] = value
              string_param_repo.create(data)
            when :secret
              data[:value] = value
              secret_param_repo.create_with_encrypt(data)
            when :integer
              data[:value] = value.to_i
              integer_param_repo.create(data)
            when :boolean
              data[:value] = value.to_i.positive?
              boolean_param_repo.create(data)
            else
              raise "Unknown param type: #{adapter.param_type(name)} " \
                "for #{name}"
            end
          end

          redirect_to routes.providers_path
        end
      end
    end
  end
end
