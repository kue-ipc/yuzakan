module Api
  module Controllers
    module Providers
      class Create
        include Api::Action

        security_level 5

        class Params < Hanami::Action::Params
          predicates NamePredicates
          messages :i18n

          params do
            required(:name).filled(:str?, :name?, max_size?: 255)
            required(:label).filled(:str?, max_size?: 255)
            required(:adapter_name).filled(:str?, :name?, max_size?: 255)
            optional(:order).maybe(:int?)
            optional(:readable).maybe(:bool?)
            optional(:writable).maybe(:bool?)
            optional(:authenticatable).maybe(:bool?)
            optional(:password_changeable).maybe(:bool?)
            optional(:lockable).maybe(:bool?)
            optional(:individual_password).maybe(:bool?)
            optional(:self_management).maybe(:bool?)
            optional(:params) { hash? }
          end
        end

        params Params

        def initialize(provider_repository: ProviderRepository.new, **opts)
          super(**opts)
          @provider_repository = provider_repository
        end

        def call(_params)
          param_errors = only_first_errors(params.errors)
          provider_params = params.to_h.dup

          if !param_errors.key?(:name) && @provider_repository.exist_by_name?(provider_params[:name])
            param_errors[:name] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:label) && @provider_repository.exist_by_label?(provider_params[:label])
            param_errors[:label] = [I18n.t('errors.uniq?')]
          end

          if !param_errors.key?(:order) && provider_params[:order] &&
             @provider_repository.exist_by_order?(provider_params[:order])
            param_errors[:order] = [I18n.t('errors.uniq?')]
          end

          halt_json(422, errors: [param_errors]) unless param_errors.empty?

          provider_params_params = provider_params.delete(:params)
          provider_params[:order] ||= @provider_repository.last_order + 8
          provider = @provider_repository.create(provider_params)

          if provider_params_params
            provider.adapter_param_types.each do |param_type|
              value = param_type.convert_value(provider_params_params[param_type.name])
              next if value.nil?

              @provider_repository.add_param({name: param_type.name.to_s, value: param_type.dump_value(value)})
            end
          end

          provider = @provider_repository.find_with_params(provider.id)

          self.status = 201
          headers['Location'] = routes.provider_path(provider.id)
          self.body = generate_json({**convert_entity(provider), params: provider.params})
        end
      end
    end
  end
end
