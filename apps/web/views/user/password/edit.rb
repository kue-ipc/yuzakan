# frozen_string_literal: true

module Web
  module Views
    module User
      module Password
        class Edit
          include Web::View

          def form
            Form.new(:user, routes.user_password_path, {}, {method: :patch})
          end

          def change_password_config
            {
              min_size: current_config.password_min_size,
              max_size: current_config.password_max_size,
              min_score: current_config.password_min_score,
              min_types: current_config.password_min_types,
              unusable_chars: current_config.password_unusable_chars,
              dict: (current_config.password_extra_dict&.split || []) +
                [
                  current_user.name,
                  current_user.display_name&.split,
                  current_user.email,
                  current_user.email&.split('@'),
                ].flatten.compact,
            }
          end

          def change_password_cols
            {
              left: 'col-sm-4',
              right: 'col-sm-8',
            }
          end
        end
      end
    end
  end
end
