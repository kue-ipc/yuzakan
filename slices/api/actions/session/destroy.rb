# frozen_string_literal: true

module API
  module Actions
    module Session
      class Destroy < API::Action
        security_level 0
        required_trusted_authentication false

        def handle(req, res) # rubocop:disable Lint/UnusedMethodArgument
          halt_json 410 unless res[:current_user]

          res.body = generate_json({
            uuid: res.session[:uuid],
            user: res.session[:user],
            created_at: res.session[:created_at],
            updated_at: res.session[:updated_at],
          })

          # セッション情報を削除
          res.session[:user] = nil
        end
      end
    end
  end
end
