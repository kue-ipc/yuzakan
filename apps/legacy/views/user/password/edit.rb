# frozen_string_literal: true

module Legacy
  module Views
    module User
      module Password
        class Edit
          include Legacy::View

          def change_password_form
            col_left = 'col-sm-4'
            col_right = 'col-sm-8'
            form_for user_password_form do
              fields_for :password do
                div id: 'change-password' do
                  div do
                    change_password_list.each do |name:, label:|
                      div class: 'form-group row' do
                        label label, class: "col-form-label #{col_left}",
                                     for: name
                        div class: col_right do
                          password_field name, change_password_field_opt(name)
                          if param_errors.key?(name.to_s)
                            div class: 'invalid-feedback' do
                              h(param_errors[name.to_s].join)
                            end
                          end
                        end
                      end
                    end
                    div class: 'row' do
                      div class: col_left
                      div class: col_right do
                        submit '変更',
                               class: 'login-submit btn btn-primary btn-block'
                      end
                    end
                  end
                end
              end
            end
          end

          private def user_password_form
            Form.new(:user, routes.user_password_path, {}, {method: :patch})
          end

          private def change_password_data
            {
              form: 'user-form',
              parents: %i[user password],
              config: change_password_config,
              cols: change_password_cols,
            }
          end

          private def change_password_list
            [
              {name: :password_current, label: '現在のパスワード'},
              {name: :password, label: '新しいパスワード'},
              {name: :password_confirmation, label: 'パスワードの確認'},
            ]
          end

          private def change_password_field_opt(name)
            password_class = ['form-control']
            password_class << 'is-invalid' if param_errors.key?(name.to_s)

            opt = {
              class: password_class,
              placeholder: 'パスワードを入力',
              required: true,
            }

            if name != :password_current
              opt.merge!(minlength: change_password_config[:min_size],
                         maxlength: change_password_config[:max_size])
              if change_password_config[:unusable_chars]&.size&.positive?
                codes = change_password_config[:unusable_chars]
                  .each_codepoint
                  .map { |code| "\\u#{format('%04x', code)}" }
                  .join
                opt.merge!(pattern: "[^#{codes}]*",
                           title: '使用不可文字を含めることはできません。')
              end
            end
            opt
          end

          private def change_password_config
            @change_password_config ||= {
              min_size: current_config.password_min_size,
              max_size: current_config.password_max_size,
              min_score: current_config.password_min_score,
              min_types: current_config.password_min_types,
              unusable_chars: current_config.password_unusable_chars,
            }
          end
        end
      end
    end
  end
end
