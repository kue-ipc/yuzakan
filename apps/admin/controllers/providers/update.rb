# frozen_string_literal: true

module Admin
  module Controllers
    module Providers
      class Update
        include Admin::Action

        def call(params)
          adapter_name = params[:provider][:adapter_name]
          adapter = ADAPTERS.by_name(adapter_name)

          repo = ProviderRepository.new
          provider = repo.find(params[:id])
          unless provider
            flash[:errors] = [
              'そのようなIDはありません。',
            ]
            redirect_to routes.providers_path
          end
          repo.update(
            provider.id,
            name: params[:provider][:name],
            display_name: params[:provider][:display_name],
            adapter_name: adapter_name,
            readable: params[:provider][:readable],
            writable: params[:provider][:writable],
            authenticatable: params[:provider][:authenticatable],
            password_changeable: params[:provider][:password_changeable],
            lockable: params[:provider][:lockable])

          string_param_repo = ProviderStringParamRepository.new
          secret_param_repo = ProviderSecretParamRepository.new
          integer_param_repo = ProviderIntegerParamRepository.new
          boolean_param_repo = ProviderBooleanParamRepository.new

          params[:provider][:params].each do |name, value|
            next if value.nil? || value.empty?

            data = {
              provider_id: provider.id,
              name: name.to_s,
            }
            case adapter.param_type(name)
            when :string
              string_param_repo.by_provider_and_name(data).each do |param|
                string_param_repo.delete(param.id)
              end
              data[:value] = value
              string_param_repo.create(data)
            when :secret
              secret_param_repo.by_provider_and_name(data).each do |param|
                secret_param_repo.delete(param.id)
              end
              data[:value] = value
              secret_param_repo.create_with_encrypt(data)
            when :integer
              integer_param_repo.by_provider_and_name(data).each do |param|
                integer_param_repo.delete(param.id)
              end
              data[:value] = value.to_i
              integer_param_repo.create(data)
            when :boolean
              boolean_param_repo.by_provider_and_name(data).each do |param|
                boolean_param_repo.delete(param.id)
              end
              data[:value] = value
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
