# frozen_string_literal: true

module API
  module Actions
    module Config
      class Update < API::Action
        include Deps[
          "repos.config_repo",
          show_view: "views.auth.show",
        ]

        params do
          required(:title).filled(:string, max_size?: 255)
          optional(:domain).maybe(:domain, max_size?: 255)
          optional(:session_timeout).filled(:integer, gteq?: 0,
            lteq?: 24 * 60 * 60)
          optional(:password_min_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:password_max_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:password_min_score).filled(:integer, gteq?: 0, lteq?: 4)
          optional(:password_prohibited_chars).maybe(:password, max_size?: 128)
          optional(:password_extra_dict).maybe(:string, max_size?: 4096)
          optional(:generate_password_size).filled(:integer, gteq?: 1,
            lteq?: 255)
          optional(:generate_password_type).filled(:string)
          optional(:generate_password_chars).maybe(:password, max_size?: 128)
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

          config = config_repo.set(**request.params.to_h)
          if config
            flash[:success] = "設定を更新しました。"
            response[:config] = config
            response.render(show_view)
          else
            flash[:failure] = "設定を更新できませんでした。"
            halt_json request, response, 422
          end
        # rescue => e
        #   logger.error e
        #   flash[:errors] << e.message
        #   flash[:error] = "エラーが発生しました。"
        #   self.body = Admin::Views::Config::Edit.render(exposures)
        end
      end
    end
  end
end
