# frozen_string_literal: true

module Admin
  module Views
    module Home
      class Index < Admin::View
        MENU_ITEMS =
          [
            {
              name: "ユーザー作成",
              action: :user,
              action_params: {id: "*"},
              description: "ユーザーを新規作成します。",
              color: "primary",
              level: 4,
            },
            {
              name: "ユーザー一覧",
              action: :users,
              description: "ユーザーの一覧です。",
              color: "secondary",
              level: 2,
            },
            {
              name: "グループ一覧",
              action: :groups,
              description: "グループの一覧です。",
              color: "secondary",
              level: 2,
            },
            {},
            {
              name: "全体設定",
              action: :edit_config,
              description: "サイト名やパスワードの条件等の設定はこちらから変更できます。",
              color: "danger",
              level: 5,
            },
            {
              name: "プロバイダー",
              action: :services,
              description: "連携するシステムはプロバイダーとして登録します。連携システムの追加や変更が可能です。",
              color: "danger",
              level: 2,
            },
            {
              name: "ユーザー属性情報",
              action: :attrs,
              description: "各プロバイダーからのユーザー属性の紐付けを行います。",
              color: "danger",
              level: 5,
            },
            {},
            {
              name: "全ユーザー情報エクスポート",
              action: :export_users,
              description: "各プロバイダーにはないユーザー情報をエクスポートします。",
              color: "warning",
              level: 5,
              filename: "users_#{Time.now.strftime('%Y%m%d_%H%M%S')}.jsonl",
            },
            {
              name: "全グループ情報エクスポート",
              action: :export_groups,
              description: "各プロバイダーにはないグループ情報をエクスポートします。",
              color: "warning",
              level: 5,
              filename: "groups_#{Time.now.strftime('%Y%m%d_%H%M%S')}.jsonl",
            },
          ].freeze
        def menu_items
          MENU_ITEMS.map do |menu|
            next {} if menu.empty?
            next if menu[:level] > current_level

            {
              name: menu[:name],
              url: routes.path(menu[:action], **menu.fetch(:action_params, {})),
              description: menu[:description],
              color: menu[:color],
            }.merge(if menu[:filename] then {type: :download,
                                             filename: menu[:filename],} else
                                                                           {} end)
          end.compact
        end
      end
    end
  end
end
