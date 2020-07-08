# frozen_string_literal: true

module Admin
  module Views
    module Dashboard
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
            {
              name: 'ユーザー一覧',
              url: routes.path(:users),
              description: 'ユーザーの一覧です。',
              color: 'primary',
            },
          ]
        end
      end
    end
  end
end

__END__
.col-auto
.card
  .card-header
    | 全体設定
  .card-body
    h5.card-title.text-white
    p.card-text
      | サイト名やパスワードの条件等の設定はこちらから変更できます。
    = link_to '全体設定の変更', routes.path(:edit_config), class: 'btn btn-primary'
.col-auto
.card
  .card-header
    | プロバイダー
  .card-body
    h5.card-title.text-white
    p.card-text
      | 連携するシステムはプロバイダーとして登録します。連携システムの追加や変更が可能です。
    = link_to 'プロバイダーの設定', routes.path(:providers), class: 'btn btn-primary'

