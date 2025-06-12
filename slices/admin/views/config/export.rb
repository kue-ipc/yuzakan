# frozen_string_literal: true

require_relative "hanami/utils/hash"

module Admin
  module Views
    module Config
      class Export < Admin::View
        format :yml

        KEYS = {
          config: %i[
            title
            domain
            session_timeout
            password_min_size
            password_max_size
            password_min_types
            password_min_score
            password_prohibited_chars
            password_extra_dict
            generate_password_size
            generate_password_type
            generate_password_chars
            contact_name
            contact_email
            contact_phone
          ],
          provider: %i[
            name
            display_name
            adapter
            readable
            writable
            authenticatable
            password_changeable
            individual_password
            lockable
            self_management
            group
          ],
          attr: %i[
            name
            display_name
            type
            hidden
            readonly
            code
          ],
        }.freeze

        def render
          data = {
            config: config_data,
            providers: providers_data,
            attrs: attrs_data,
          }
          raw YAML.dump(Hanami::Utils::Hash.deep_stringify(data))
        end

        private def config_data
          KEYS[:config].to_h { |key| [key, current_config.__send__(key)] }
        end

        private def providers_data
          providers.map do |provider|
            provider_data = KEYS[:provider].to_h do |key|
              [key, provider.__send__(key)]
            end
            adapter_params_data = provider.adapter_param_types.to_h do |param_type|
              [param_type.name.to_s, provider.params[param_type.name]]
            end
            {
              **provider_data,
              params: adapter_params_data,
            }
          end
        end

        private def attrs_data
          attrs.map do |attr|
            attr_data = KEYS[:attr].to_h { |key| [key, attr.__send__(key)] }

            mappings_data = attr.mappings.map do |mapping|
              {
                provider: providers.find do |provider|
                  provider.id == mapping.provider_id
                end&.name,
                key: mapping.key,
                conversion: mapping.conversion,
              }
            end

            {
              **attr_data,
              mappings: mappings_data,
            }
          end
        end
      end
    end
  end
end
