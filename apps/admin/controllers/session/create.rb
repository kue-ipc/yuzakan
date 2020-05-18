# frozen_string_literal: true

module Admin
  module Controllers
    module Session
      class Create
        include Admin::Action

        def call(params)
          result = Authenticate.new(client: remote_ip)
            .call(params[:session])

          if result.failure?
            errors, param_errors = devide_errors(result.errors)
            if format == :html
              flash[:errors] = errors
              flash[:param_errors] = param_errors
              flash[:failure] = 'ログインに失敗しました。'
              redirect_to routes.new_session_path
            elsif format == :json
              @data = {
                result: 'failure',
                messages: {
                  errors: errors,
                  param_errors: param_errors,
                  failure: 'ログインに失敗しました。',
                },
              }
            end
            return
          end

          role = RoleRepository.new.find(result.user.role_id)

          unless role&.admin
            session[:user_id] = nil
            if format == :html
              flash[:failure] = '管理者権限がありません。'
              redirect_to routes.new_session_path
            elsif format == :json
              @data = {
                result: 'failure',
                messages: {
                  failure: '管理者権限がありません。',
                },
              }
            end
            return
          end

          session[:user_id] = result.user.id
          session[:access_time] = Time.now
          if format == :html
            flash[:success] = 'ログインしました。'
            redirect_to routes.path(:dashboard)
          elsif format == :json
            @data = {
              result: 'success',
              messages: {success: 'ログインしました。'},
            }
          end
        end

        def authenticate!; end
      end
    end
  end
end
