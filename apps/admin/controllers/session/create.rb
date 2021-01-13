require 'hanami/action/cache'

module Admin
  module Controllers
    module Session
      class Create
        include Admin::Action
        include Hanami::Action::Cache

        cache_control :no_store

        expose :data

        def call(params)
          result = Authenticate.new(client: remote_ip, app: 'admin')
            .call(params[:session])

          if result.failure?
            case format
            when :html
              flash[:errors] = result.errors
              flash[:failure] = 'ログインに失敗しました。'
              redirect_to routes.path(:root)
            when :json
              @data = {
                result: 'failure',
                messages: {
                  errors: result.errors,
                  failure: 'ログインに失敗しました。',
                },
              }
            end
            return
          end

          unless result.user.admin
            session[:user_id] = nil
            case format
            when :html
              flash[:failure] = '管理者権限がありません。'
              redirect_to routes.path(:root)
            when :json
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
          case format
          when :html
            flash[:success] = 'ログインしました。'
            redirect_to routes.path(:dashboard)
          when :json
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
