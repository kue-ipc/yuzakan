# frozen_string_literal: true

module Web
  module Views
    module Session
      class New
        include Web::View

        def form
          form_for :session, routes.session_path do
            div do
              label 'ユーザー名'
              text_field :username
            end
            div do
              label 'パスワード'
              password_field :password
            end
            submit 'ログイン'
          end
        end
      end
    end
  end
end
