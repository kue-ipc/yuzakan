# frozen_string_literal: true

require 'securerandom'
require 'net/ldap'
require 'smbhash'
require 'base64'

# パスワード変更について
# userPassword は {CRYPT}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'base_adapter'
require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class ActiveDirectoryAdapter < LdapAdapter
      def self.label
        'Active Directory'
      end

      def self.usable?
        true
      end

      def self.params
        @params ||= [
          {
            name: 'host',
            label: 'ドメインコントローラーのホスト名/IPアドレス',
            description:
              'ドメインコントローラーのホスト名またはIPアドレスを指定します。',
            type: :string,
            required: true,
            placeholder: 'dc.example.jp',
          }, {
            name: 'base_dn',
            label: 'ベースDN',
            description: '全てベースです。',
            type: :string,
            required: false,
            placeholder: 'dc=example,dc=jp',
          }, {
            name: 'bind_username',
            label: '接続ユーザー',
            type: :string,
            required: true,
            placeholder: 'Administrator@example.jp',
          }, {
            name: 'bind_password',
            label: '接続ユーザーのパスワード',
            type: :secret,
            required: true,
          }, {
            name: 'user_base',
            label: 'ユーザー検索のベース',
            description: 'ユーザー検索を行うときのツリーベースです。指定しない場合はLDAPサーバーのベースから検索します。',
            type: :string,
            required: false,
            placeholder: 'ou=Users,dc=example,dc=jp',
          }, {
            name: 'user_scope',
            label: 'ユーザー検索のスコープ',
            description: 'ユーザー検索を行うときのスコープです。デフォルトは sub です。',
            type: :string,
            required: true,
            list: [
              {
                name: 'ベースのみ検索(base)',
                value: 'base',
              }, {
                name: 'ベース直下のみ検索(one)',
                value: 'one',
              }, {
                name: 'ベース配下全て検索(sub)',
                value: 'sub',
              },
            ],
            default: 'sub',
          }, {
            name: 'user_filter',
            label: 'ユーザー検索のフィルター',
            description:
              'ユーザー検索を行うときのフィルターです。' \
              'LDAPの形式で指定します。' \
              '何も指定しない場合は(objectclass=user)になります。',
            type: :string,
            required: false,
            placeholder: '(objectclass=user)',
          },
        ]
      end

      def initialize(params)
        super(params.merge(
          protocol: 'ldaps',
          port: 636,
          user_name_attr: 'cn',
        ))
        if @params[:user_filter] && !@params[:user_filter].empty?
          @params[:user_filter] = '(objectclass=user)'
        end
      end

      # TODO: 要確認
      # 初期作成のユーザーは'add'じゃないとエラーになるかもしれない。
      # パスワードが削除されている状況はあり得るのだろうか？
      def change_password(username, password)
        ldap = generate_ldap
        user = ldap.search(search_user_opts(username))&.first
        return false unless user

        operations = []
        operations << [
          :replace,
          :unicodePwd,
          [generate_password(password)],
        ]

        result = ldap.modify(
          dn: user.dn,
          operations: operations
        )
        true
      end

      # ダブルコーテーションで囲ってUTF-16LEに変更する。
      private def generate_password(password)
        "\"#{password}\"".encode(Encoding::UTF_16LE).bytes.pack('c*')
      end
    end
  end
end
