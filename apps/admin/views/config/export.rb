module Admin
  module Views
    module Config
      class Export
        include Admin::View

        format :yml

        def render
          data = {}
          data['config'] = {}
          %w[
            title
            session_timeout
            password_min_size
            password_max_size
            password_min_types
            password_min_score
            password_unusable_chars
            password_extra_dict
            admin_networks
            user_networks
            contact_name
            contact_email
            contact_phone
          ].each do |key|
            data['config'][key] = current_config.__send__(key)
          end

          data['providers'] = []
          provider_ids = {}
          providers.each do |provider|
            provider_ids[provider.id] = provider
            next if provider.immutable

            provider_data = {}
            %w[
              name
              display_name
              adapter_name
              order
              immutable
              readable
              writable
              authenticatable
              password_changeable
              lockable
              individual_password
              self_management
            ].each do |key|
              provider_data[key] = provider.__send__(key)
            end

            provider_data['params'] = {}
            params = provider.params

            provider_data['params'] = provider.adapter_param_types.to_h do |param_type|
              [param_type.name.to_s, params[param_type.name]]
            end
            data['providers'] << provider_data
          end

          data['attrs'] = []
          attrs.each do |attr|
            attr_data = {}
            %w[
              name
              display_name
              type
              order
              hidden
            ].each do |key|
              attr_data[key] = attr.__send__(key)
            end

            attr_data['attr_mappings'] = attr.attr_mappings.map do |attr_mapping|
              {
                'provider_name' => provider_ids[attr_mapping.provider_id].name,
                'name' => attr_mapping.name,
                'conversion' => attr_mapping.conversion,
              }
            end

            data['attrs'] << attr_data
          end

          raw YAML.dump(data)
        end
      end
    end
  end
end
