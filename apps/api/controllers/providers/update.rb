module Api
  module Controllers
    module Providers
      class Update
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:id).filled(:str?, :name?, max_size?: 255)
            optional(:name).filled(:str?, :name?, max_size?: 255)
            optional(:label).filled(:str?, max_size?: 255)
            optional(:adapter_name).filled(:str?, :name?, max_size?: 255)
            optional(:order).maybe(:int?)
            optional(:readable).maybe(:bool?)
            optional(:writable).maybe(:bool?)
            optional(:authenticatable).maybe(:bool?)
            optional(:password_changeable).maybe(:bool?)
            optional(:lockable).maybe(:bool?)
            optional(:individual_password).maybe(:bool?)
            optional(:self_management).maybe(:bool?)
            # rubocop:disable all
            optional(:params) { array? { each { schema {
              predicates NamePredicates
              required(:name).filled(:str?, :name?, max_size?: 255)
              required(:value)
            } } } }
            # rubocop:enable all
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new,
                       provider_param_repository: ProviderParamRepository.new,
                       **opts)
          super(**opts)
          @provider_repository = provider_repository
          @provider_param_repository = provider_param_repository
        end

        def call(params)
          halt_json 400, errors: [params.errors.slice(:id)] if params.errors.key?(:id)

          provider = @provider_repository.find_with_params_by_name(params[:id])
          halt_json 404 if @provider.nil?

          param_errors = only_first_errors(params.errors.to_h)
          provider_params = params.to_h.dup

          if !param_errors.key?(:name) && provider_params[:name] && provider_params[:name] != provider.name &&
             @provider_repository.exist_by_name?(provider_params[:name])
            param_errors[:name] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:label) && provider_params[:label] && provider_params[:label] != provider.label &&
             @provider_repository.exist_by_label?(provider_params[:label])
            param_errors[:label] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:order) && provider_params[:order] && provider_params[:order] != provider.order &&
             @provider_repository.exist_by_order?(provider_params[:order])
            param_errors[:order] = [I18n.t('errors.uniq?')]
          end

          halt_json 422, errors: [param_errors] unless param_errors.empty?

          provider_params_params = provider_params.delete(:params)
          provider_params[:order] ||= @provider_repository.last_order + 8
          @provider_repository.update(provider.id, provider_params)

          if provider_params_params
            existing_params = provider.params.dup
            provider.adapter_param_types.each do |param_type|
              value = param_type.convert_value(provider_params_params[param_type.name])
              next if value.nil?

              if existing_params.key?(param_type.name)
                existing_value = existing_params.delete(param_type.name)
                if existing_value != value
                  existing_provider_param = provider.provider_params.find do |param|
                    param.name == param_type.name.name
                  end
                  @provider_param_repository.update(existing_provider_param.id, {value: param_type.dump_value(value)})
                end
              else
                @provider_repository.add_param({name: param_type.name.to_s, value: param_type.dump_value(value)})
              end
            end
            existing_params.each_key do |key|
              @provider_repository.delete_param_by_name(provider, key)
            end
          end

          updated_provider = @provider_repository.find_with_params(provider.id)

          self.status = 200
          self.body = generate_json({**convert_entity(updated_provider), params: updated_provider.params})
        end
      end
    end
  end
end
