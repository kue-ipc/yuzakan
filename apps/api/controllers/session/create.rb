module Api
  module Controllers
    module Session
      class Create
        include Api::Action

        expose :result
        security_level 0

        def initialize(authenticate: Authenticate.new, **opts)
          super(**opts)
          @authenticate = authenticate
        end

        def call(params)
          authenticate_result = @authenticate.call(**params[:session], uuid: uuid, client: remote_ip, )

          @result =
            if authenticate_result.successful?
              # セッション情報を保存
              session[:user_id] = authenticate_result.user.id

              {
                result: 'success',
                messages: {success: 'ログインしました。'},
              }
            else
              self.status = 422
              {
                result: 'failure',
                messages: {
                  errors: authenticate_result.errors,
                  failure: 'ログインに失敗しました。',
                },
              }
            end
        end
      end
    end
  end
end
