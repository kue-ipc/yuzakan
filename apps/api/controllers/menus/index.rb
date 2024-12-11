# frozen_string_literal: true

module Api
  module Controllers
    module Menus
      class Index
        include Api::Action

        security_level 0

        def initialize(provider_repository: ProviderRepository.new,
                       **opts)
          super
          @provider_repository ||= provider_repository
        end

        def call(params) # rubocop:disable Lint/UnusedMethodArgument
          menus = []

          if current_level >= 1
            menu.push({
              name: "利用者メニュー",
              path: Web.routes.path(:root),
              description: "利用者のメニューです。",
              color: "primary",
              icon: "house",
              categroy: "top",
            }, {
              name: "パスワード変更",
              path: Web.routes.path(:edit_password),
              description: "アカウントのパスワードを変更します。",
              color: "primary",
              icon: "lock",
              categroy: "user",
            })
            @provider_repository.self_management.each do |provider|
              menu << {
                name: provider.display_name,
                url: Web.routes.path(:providers, provider.name),
                description: "#{provider.display_name}のアカウントを操作します。",
                color: "secondary",
                icon: adapter_icon(provider.adapter_name),
                category: "user",
              }
            end
          end

          if current_level >= 2
            menu.push({
              name: "利用者メニュー",
              path: Web.routes.path(:root),
              description: "利用者のメニューです。",
              color: "primary",
              icon: "house-heart",
              category: "top",
            }, {
              name: "ユーザー一覧",
              url: routes.path(:users),
              description: "ユーザーの一覧です。",
              color: "secondary",
              icon: "person",
              category: "admin",
            }, {
              name: "グループ一覧",
              url: routes.path(:groups),
              description: "グループの一覧です。",
              color: "secondary",
              icon: "people",
              category: "admin",
            })
          end

          menu.push if current_level >= 3

          if current_level >= 4
            menu.push({
              name: "ユーザー作成",
              url: routes.path(:user, "*"),
              description: "ユーザーを新規作成します。",
              color: "primary",
              icon: "person-plus",
              category: "admin",
            })
          end

          if current_level >= 5
            menu.push({
              name: "全体設定",
              url: routes.path(:edit_config),
              description: "サイト名やパスワードの条件等の設定はこちらから変更できます。",
              color: "danger",
              icon: "gear",
              category: "admin",
            }, {
              name: "プロバイダー",
              url: routes.path(:providers),
              description: "連携するシステムはプロバイダーとして登録します。連携システムの追加や変更が可能です。",
              color: "danger",
              icon: "hhd-stack",
              category: "admin",
            }, {
              name: "ユーザー属性情報",
              url: routes.path(:attrs),
              description: "各プロバイダーからのユーザー属性の紐付けを行います。",
              color: "danger",
              category: "admin",
            })
          end
          self.body = generate_json(menus)
        end

        def configurate!
        end

        private def adapter_icon(adapter_name)
          case adapter_name
          when "google"
            "google"
          when "microsoft"
            "microsoft"
          when "ad"
            "windows"
          when /ldap/
            "diagram-3"
          else
            "server"
          end
        end
      end
    end
  end
end
