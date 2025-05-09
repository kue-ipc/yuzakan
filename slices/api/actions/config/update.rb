# frozen_string_literal: true

module API
  module Actions
    module Config
      class Update < API::Action
        include Deps[
          "repos.config_repo",
        ]

        params do
          required(:title).filled(:string, max_size?: 255)
          optional(:domain).maybe(Yuzakan::Types::DomainString, max_size?: 255)
          optional(:session_timeout)
            .filled(:integer, gteq?: 0, lteq?: 24 * 60 * 60)
          optional(:password_min_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:password_max_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:password_min_score).filled(:integer, gteq?: 0, lteq?: 4)
          optional(:password_prohibited_chars)
            .maybe(Yuzakan::Types::PasswordString, max_size?: 128)
          optional(:password_extra_dict).maybe(:string, max_size?: 4096)
          optional(:generate_password_size).filled(:integer, gteq?: 1, lteq?: 255)
          optional(:generate_password_type).filled(:string)
          optional(:generate_password_chars)
            .maybe(Yuzakan::Types::PasswordString, max_size?: 128)
          optional(:contact_name).maybe(:string, max_size?: 255)
          optional(:contact_email)
            .maybe(Yuzakan::Types::EmailString, max_size?: 255)
          optional(:contact_phone).maybe(:string, max_size?: 255)
        end

        security_level 5

        def handle(_request, _response)
          flash[:errors] ||= []

          @config = params[:config] || current_config

          unless params.valid?
            flash[:errors] << params.errors
            flash[:error] = "設定に失敗しました。"
            self.body = Admin::Views::Config::Edit.render(exposures)
            return
          end

          @config_repository.current_update(@config)

          flash[:success] = "設定を更新しました。"
          redirect_to routes.path(:edit_config)
        rescue => e
          logger.error e
          flash[:errors] << e.message
          flash[:error] = "エラーが発生しました。"
          self.body = Admin::Views::Config::Edit.render(exposures)
        end
      end
    end
  end
end
