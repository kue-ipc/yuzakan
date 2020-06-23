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
                url: '#gsuite-unlock-user',
                description: 'Google アカウントのロックを解除します。同時にパスワードもリセットされます。',
                color: 'warning',
                type: :modal,
              }
            else
              items << {
                name: 'パスワードリセット',
                url: '#gsuite-unlock-user',
                description: 'Google アカウントのパスワードをリセットします。同時に二段階認証設定もリセットします。',
                color: 'warning',
                type: :modal,
              }
            end
            items << {
              name: 'アカウント削除',
              url: '#gsuite-destroy-user',
              description: 'Google アカウントを削除します。',
              color: 'danger',
              type: :modal,
            }
          else
            items << {
              name: 'アカウント作成',
              url: '#gsuite-create-user',
              description: 'Googleアカウントを作成します。',
              color: 'primary',
              type: :modal,
            }
          end
          items
        end

        def gsuite_create_user_rules
          [
            '作成されるGoogleアカウントは大学メールアドレスになります。',
            'アカウント作成にあたり、Google社へアカウント作成に必要な情報(氏名、メールアドレス、身分、グループ等)を送信します。',
            '個人向けGoogleアカウントとは異なり、大学の情報管理者はアカウントのすべてを監視・管理できる権限を持っています。大学の情報管理者は、大学の情報利用に関する各規程で定められた権限の範囲内で監視・管理を実施します。',
            '初回ログイン時にGoogle社の規約に同意し、遵守しなければなりません。',
            'アカウントを用いた各サービスの利用は、大学の情報利用に関する各規定に準じ、これを遵守しなければなりません。違反があった場合は、アカウントの停止等の処理を実施する場合があります。',
            'プライベートのアカウントではなく、大学の正式なアカウントであることの自覚を持って利用しなければなりません。',
          ]
        end
      end
    end
  end
end
