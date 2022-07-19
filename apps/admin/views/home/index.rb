module Admin
  module Views
    module Home
      class Index
        include Admin::View

        def menu_items
          [
            {
              name: '全体設定',
              url: routes.path(:edit_config),
              description: 'サイト名やパスワードの条件等の設定はこちらから変更できます。',
              color: 'danger',
            },
            {
              name: 'プロバイダー',
              url: routes.path(:providers),
              description: '連携するシステムはプロバイダーとして登録します。連携システムの追加や変更が可能です。',
              color: 'danger',
            },
            {
              name: 'ユーザー属性情報',
              url: routes.path(:attrs),
              description: '各プロバイダーからのユーザー属性の紐付けを行います。',
              color: 'danger',
            },
            {},
            {
              name: 'ユーザー作成',
              url: routes.path(:user, '*'),
              description: 'ユーザーを新規作成します。',
              color: 'primary',
            },
            {
              name: 'ユーザー一覧',
              url: routes.path(:users),
              description: 'ユーザーの一覧です。',
              color: 'secondary',
            },
            {
              name: 'グループ一覧',
              url: routes.path(:groups),
              description: 'グループの一覧です。',
              color: 'seconadry',
            },
          ]
        end
      end
    end
  end
end
