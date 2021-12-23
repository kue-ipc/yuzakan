require 'securerandom'
require 'net/ldap'
require 'smbhash'
require 'base64'

require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class AdAdapter < LdapAdapter
      LABEL = 'Active Directory'

      PARAMS = [
        {
          name: 'host',
          label: 'ドメインコントローラーのホスト名/IPアドレス',
          description:
            'ドメインコントローラーのホスト名またはIPアドレスを指定します。',
          type: :string,
          required: true,
          placeholder: 'dc.example.jp',
        }, {
          name: 'certificate_check',
          label: '証明書チェックを行う。',
          description:
            'サーバー証明書のチェックを行います。ドメインコントローラーには正式証明書が必要になります。',
          type: :boolean,
          default: false,
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
          type: :string,
          input: 'password',
          required: true,
          encrypted: true,
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

      def self.label
        LABEL
      end

      def self.selectable?
        true
      end

      def self.params
        PARAMS
      end

      def initialize(params)
        super(params.merge(
          protocol: 'ldaps',
          port: 636,
          user_name_attr: 'cn'))
        if @params[:user_filter] && !@params[:user_filter].empty?
          @params[:user_filter] = '(objectclass=user)'
        end
      end

      # 初期作成のユーザーは'add'じゃないとエラーになるかもしれない。
      # パスワードが削除されている状況はあり得るのだろうか？
      private def change_password_operations(password, existing_attrs = [])
        [generate_operation_replace(:unicodePwd, generate_unicode_password(password))]
      end

      # ダブルコーテーションで囲ってUTF-16LEに変更する。
      private def generate_unicode_password(password)
        "\"#{password}\"".encode(Encoding::UTF_16LE).bytes.pack('c*')
      end
    end
  end
end
