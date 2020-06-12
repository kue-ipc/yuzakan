# frozen_string_literal: true

module Web
  module Controllers
    module Session
      class Create
        include Web::Action
        expose :data

        def call(params)
          result = Authenticate.new(client: remote_ip)
            .call(params[:session])

          if result.failure?
            errors, param_errors = devide_errors(result.errors)
            if format == :html
              flash[:errors] = errors
              flash[:param_errors] = param_errors
              flash[:failure] = 'ログインに失敗しました。'
              redirect_to routes.path(:root)
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

          # セッション情報を保存
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

        def authenticate!
        end
      end
    end
  end
end
