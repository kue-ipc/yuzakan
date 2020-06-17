# frozen_string_literal: true

module Admin
  module Views
    module Dashboard
      class Index
        include Admin::View

        def menu_link(name:, url:, description:)
          link_to url, class: 'card' do
            div name, class: 'card-header text-center'
            div description, class: 'card-body'
          end
        end

        def menu_items
          [
            {
              name: '全体設定',
              url: routes.path(:edit_config),
              description: 'サイト名やパスワードの条件等の設定はこちらから変更できます。',
            },
            {
              name: 'プロバイダー',
              url: routes.path(:providers),
              description: '連携するシステムはプロバイダーとして登録します。連携システムの追加や変更が可能です。',
            },
            {
              name: 'ユーザー属性情報',
              url: routes.path(:attr_types),
              description: '各プロバイダーからのユーザー属性の紐付けを行います。',
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

