# frozen_string_literal: true

module Api
  module Controllers
    module Self
      module Password
        class Update
          include Api::Action

          class Params < Hanami::Action::Params
            predicates NamePredicates
            messages :i18n

            params do
              required(:current_password).filled(:str?)
              required(:password).filled(:str?).confirmation
              required(:password_confirmation).filled(:str?)
            end
          end

          params Params

          def initialize(provider_repository: ProviderRepository.new,
                         user_notify: Mailers::UserNotify,
                         **opts)
            super(**opts)
            @provider_repository = provider_repository
            @user_notify = user_notify
          end

          def call(params)
            param_errors = only_first_errors(params.errors)

            unless param_errors.key?(:password)
              password_size = params[:password].size
              if current_config.password_min_size&.>(password_size)
                param_errors[:name] = [I18n.t('errors.min_size?', num: current_config.password_min_size)]
              elsif current_config.password_max_size&.<(password_size)
                param_errors[:name] = [I18n.t('errors.max_size?', num: current_config.password_max_size)]
              end

              if params[:password] !~ /\A[\u0020-\u007e]*\z/ ||
                 !((current_config.password_unusable_chars&.chars || []) & params[:password].chars).empty?
                param_errors[:name] ||= []
                param_errors[:name] << I18n.t('errors.valid_chars?')
              end

              password_types = [/[0-9]/, /[a-z]/, /[A-Z]/, /[^0-9a-zA-Z]/].select do |reg|
                reg.match(params[:password])
              end.size
              if current_config.password_min_types&.> password_types
                param_errors[:name] ||= []
                param_errors[:name] << I18n.t('errors.min_types?', num: current_config.password_min_types)
              end

              dict = (current_config.password_extra_dict&.split || []) +
                     [
                       current_user.name,
                       current_user.display_name&.split,
                       current_user.email,
                       current_user.email&.split('@'),
                       params[:current_password],
                     ].flatten.compact

              password_score = Zxcvbn.test(params[:password], dict).score
              if current_config.password_min_score&.>(password_score)
                param_errors[:name] ||= []
                param_errors[:name] << I18n.t('errors.strong_password?')
              end

            end

            halt_json(422, errors: [param_errors]) unless param_errors.empty?

            change_password = ProviderChangePassword.new(provider_repository: @provider_repository)
            result = change_password.call(username: current_user.name, password: params[:password])

            halt_json 500, errors: result.errors if result.failure?

            if current_user.email
              @user_notify.deliver(
                user: current_user,
                config: current_config,
                by_user: :self,
                action: 'パスワード変更',
                description: 'アカウントのパスワードを変更しました。')
            end

            self.status = 200
            self.body = generate_json({
              password: {
                size: password_size,
                types: password_types,
                score: password_score,
              },
            })
          end
        end
      end
    end
  end
end
