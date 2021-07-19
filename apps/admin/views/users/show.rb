module Admin
  module Views
    module Users
      class Show
        include Admin::View

        include Yuzakan::Helpers::Modal

        def user_password_form
        end

        def user_password_modal
          id = :user_password
          modal(id, Form.new(id, routes.path(:user_password, user.name)),
                title: 'パスワードリセット',
                submit_button: {
                  label: 'パスワードリセット実行',
                  color: 'danger',
                }) do
            p <<~DOC
              #{user.name}のパスワードをリセットします。
              リセット後のパスワードは実行後に表示されます。
              元のパスワードに戻すことはできません。
              本人からの依頼であることが確実である場合のみ実施してください。
            DOC
            p '本当に実行してもよろしいですか？'
          end
        end
      end
    end
  end
end
