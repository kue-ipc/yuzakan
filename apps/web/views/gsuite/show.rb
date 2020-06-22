# frozen_string_literal: true

module Web
  module Views
    module Gsuite
      class Show
        include Web::View

        def menu_items
          items = []
          if gsuite_user
            if gsuite_user[:locked]
              items << {
                name: 'ロック解除',
                url: '#unlock-user',
                description: 'Google アカウントのロックを解除します。同時にパスワードもリセットされます。',
                color: 'warning',
                type: :modal,
              }
            else
              items << {
                name: 'パスワードリセット',
                url: '#unlock-user',
                description: 'Google アカウントのパスワードをリセットします。同時に二段階認証設定もリセットします。',
                color: 'warning',
                type: :modal,
              }
            end
            items << {
              name: 'アカウント削除',
              url: '#destroy-user',
              description: 'Google アカウントを削除します。',
              color: 'danger',
              type: :modal,
            }
          else
            items << {
              name: 'アカウント作成',
              url: '#create-user',
              description: 'Googleアカウントを作成します。',
              color: 'primary',
              type: :modal,
            }
          end
          items
        end
      end
    end
  end
end
