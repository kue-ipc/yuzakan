# frozen_string_literal: true

module API
  module Actions
    module Config
      class Update < API::Action
        include Deps[
          "repos.config_repo",
          show_view: "views.config.show"
        ]

        params do
          required(:title).filled(:string, max_size?: 255)
          optional(:domain).maybe(:domain, max_size?: 255)

          optional(:session_timeout)
            .filled(:integer, gteq?: 0, lteq?: 24 * 60 * 60)

          optional(:auth_failure_limit)
            .filled(:integer, gteq?: 0, lteq?: 100_000)
          optional(:auth_failure_duratio)
            .filled(:integer, gteq?: 0, lteq?: 24 * 60 * 60)

          optional(:password_min_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:password_max_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:password_min_types).filled(:integer, gteq?: 0, lteq?: 4)
          optional(:password_prohibited_chars).value(:password, max_size?: 255)

          optional(:password_min_score).filled(:integer, gteq?: 0, lteq?: 4)
          optional(:password_extra_dict).maybe(array[:string], max_size?: 4096)

          optional(:generate_password_size)
            .filled(:integer, gteq?: 1, lteq?: 255)
          optional(:generate_password_type)
            .filled(:string,
              included_in?: Yuzakan::Operations::GeneratePassword::TYPES)
          optional(:generate_password_chars).value(:password, max_size?: 255)

          optional(:contact_name).maybe(:string, max_size?: 255)
          optional(:contact_email).maybe(:email, max_size?: 255)
          optional(:contact_phone).maybe(:string, max_size?: 255)
        end

        security_level 5

        def handle(request, response)
          unless request.params.valid?
            response.flash[:invalid] = request.params.errors
            halt_json request, response, 422
          end

          params = request.params.to_h
          params = convert_unique_chars(:password_prohibited_chars, params)
          params = convert_unique_chars(:generate_password_chars, params)

          config = config_repo.set(**params)
          unless config
            response.flash[:success] =
              t("messages.action.failuer", action: t("actions.update_config"))
            halt_json request, response, 422
          end

          response.flash[:success] =
            t("messages.action.success", action: t("actions.update_config"))
          response[:config] = config
          response.render(show_view)
        end

        private def convert_unique_chars(name, params)
          return params unless params[name]

          params.merge({name => params[name].each_char.uniq.sort.join})
        end
      end
    end
  end
end
