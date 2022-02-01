module Web
  module Controllers
    module Session
      class Create
        include Web::Action

        expose :data
        security_level 0

        def call(params)
          result = Authenticate.new(client: remote_ip, app: 'web')
            .call(params[:session])

          if result.failure?
            case format
            when :html
              flash[:errors] = result.errors
              flash[:failure] = 'ログインに失敗しました。'
              redirect_to routes.path(:root)
            when :json
              self.status = 422
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

          # セッション情報を保存
          session[:user_id] = result.user.id
          session[:access_time] = Time.now

          case format
          when :html
            flash[:success] = 'ログインしました。'
            redirect_to routes.path(:root)
          when :json
            @data = {
              result: 'success',
              messages: {success: 'ログインしました。'},
            }
          end
        end
      end
    end
  end
end
