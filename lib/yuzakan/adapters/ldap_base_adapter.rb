require 'securerandom'
require 'net/ldap'

require 'base64'
require 'digest'

# パスワード変更について
# userPassword は {crypt}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'abstract_adapter'

module Yuzakan
  module Adapters
    class LdapBaseAdapter < AbstractAdapter
      self.abstract_adapter = true
      self.params = [
        {
          name: :host,
          label: 'サーバーのホスト名/IPアドレス',
          description: 'LDAPサーバーのホスト名またはIPアドレスを指定します。',
          type: :string,
          placeholder: 'ldap.example.jp',
        }, {
          name: :port,
          label: 'ポート',
          description: 'LDAPサーバーにアクセスするポート番号をして指定します。' \
                       '指定しない場合は既定値(LDAPは389、LDAPSは636)を使用します。',
          type: :integer,
          required: false,
          placeholder: '389 or 636',
        }, {
          name: :protocol,
          label: 'プロトコル/暗合形式',
          description: 'LDAPサーバーにアクセスするプロトコルを指定します。',
          type: :string,
          default: 'ldaps',
          list: [
            {name: :ldap, label: 'LDAP(平文)', value: 'ldap', deprecated: true},
            {name: :ldap_starttls, label: 'LDAP+STARTTLS(暗合)', value: 'ldap_starttls'},
            {name: :ldaps, label: 'LDAPS(暗合)', value: 'ldaps'},
          ],
          input: 'radio',
        }, {
          name: :certificate_check,
          label: '証明書チェックを行う。',
          description: 'サーバー証明書のチェックを行います。' \
                       'LDAPサーバーには正式証明書が必要になります。',
          type: :boolean,
          default: true,
        }, {
          name: :base_dn,
          label: 'ベースDN',
          description: '全てベースです。',
          type: :string,
          placeholder: 'dc=example,dc=jp',
        }, {
          name: :bind_username,
          label: '接続ユーザー名',
          type: :string,
          placeholder: 'cn=Admin,dc=example,dc=jp',
        }, {
          name: :bind_password,
          label: '接続ユーザーのパスワード',
          type: :string,
          encrypted: true,
          input: 'password',
        }, {
          name: :user_dn_attr,
          label: 'ユーザーDNの属性',
          type: :string,
          placeholder: 'cn',
        }, {
          name: :user_ou_dn,
          label: 'ユーザーのOU',
          description: 'ユーザー作成するときのOUです。' \
                       '指定しない場合はユーザー検索のベースに作成します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users',
        }, {
          name: :user_name_attr,
          label: 'ユーザー名の属性',
          type: :string,
          placeholder: 'cn',
        }, {
          name: :user_display_name_attr,
          label: 'ユーザー表示名の属性',
          type: :string,
          default: 'displayName;lang-ja',
          placeholder: 'displayName;lang-ja',
        }, {
          name: :user_email_attr,
          label: 'ユーザーメールの属性',
          type: :string,
          default: 'mail',
          placeholder: 'mail',
        }, {
          name: :user_search_base_dn,
          label: 'ユーザー検索のベースDN',
          description: 'ユーザー検索を行うときのベースです。' \
                       '指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users',
        }, {
          name: :user_search_scope,
          label: 'ユーザー検索のスコープ',
          description: 'ユーザー検索を行うときのスコープです。' \
                       '通常は sub を使用します。',
          type: :string,
          default: 'sub',
          list: [
            {name: :base, label: 'ベースのみ検索(base)', value: 'base'},
            {name: :one, label: 'ベース直下のみ検索(one)', value: 'one'},
            {name: :sub, label: 'ベース配下全て検索(sub)', value: 'sub'},
          ],
        }, {
          name: :user_search_filter,
          label: 'ユーザー検索のフィルター',
          description:
        'ユーザー検索を行うときのフィルターです。' \
        'LDAPの形式で指定します。' \
        '何も指定しない場合は(objectclass=*)になります。',
          type: :string,
          default: '(objectclass=*)',
          required: false,
        },
      ]

      class << self
        attr_accessor :multi_attrs, :hide_attrs
      end

      self.multi_attrs = %w[objectClass]
      self.hide_attrs = []

      def check
        base = ldap.search(
          base: @params[:base_dn],
          scope: Net::LDAP::SearchScope_BaseObject)&.first
        if base
          true
        else
          false
        end
      end

      def create(username, password = nil, **attrs)
        return nil if read(username)

        user_data = attrs.filter { |key, _| key.is_a?(String) }.transform_keys { |key| attribute_name(key) }
        user_data[attribute_name(@params[:user_name_attr])] = attrs[:username]
        user_data[attribute_name(@params[:user_display_name_attr])] = attrs[:display_name] if attrs[:display_name]
        user_data[attribute_name(@params[:user_email_attr])] = attrs[:email] if attrs[:email]

        dn = "#{@params[:user_dn_attr]}=#{ldap_attrs[@params[:user_dn_attr].intern]},#{@params[:user_base]}"

        raise ldap.get_operation_result.error_message unless ldap.add(dn: dn, attributes: user_data)

        change_password(username, password) if password

        read(username)
      end

      def read(username)
        opts = search_user_opts(username)
        result = ldap.search(opts)
        entry2userdata(result.first) if result
      end

      def udpate(username, **attrs)
        raise NotImplementedError
      end

      def delete(username)
        raise NotImplementedError
      end

      def auth(username, password)
        opts = search_user_opts(username).merge(password: password)
        # bind_as is re bind, so DON'T USE `ldap`
        result = generate_ldap.bind_as(opts)
        entry2userdata(result.first) if result
      end

      def change_password(username, password)
        user_attrs = read(username)
        return nil unless user_attrs

        operations = change_password_operations(password)

        modify_result = ldap.modify(dn: user_attrs['dn'], operations: operations)
        raise ldap.get_operation_result.error_message unless modify_result

        user_attrs
      end

      def list
        generate_ldap.search(search_user_opts('*')).map do |user|
          user[@params[:user_name_attr]]&.first
        end
      end

      def search(query)
        []
        # local_users.where { 
        #   name.like('%?%', query) || display_name.like('%?%', query) || email.like('%?%', query)
        # }
      end
    
      private def change_password_operations(_password)
        raise NotImplementedError
      end

      private def generate_operation(operator, name, value = nil)
        raise "invalid operator: #{operator}" unless [:add, :replace, :delete].include?(operator)

        [operator, name, value]
      end

      private def generate_operation_add(name, value)
        generate_operation(:add, name, value)
      end

      private def generate_operation_replace(name, value)
        generate_operation(:replace, name, value)
      end

      private def generate_operation_delete(name)
        generate_operation(:delete, name, nil)
      end

      private def ldap
        @ldap ||= generate_ldap
      end

      private def generate_ldap
        opts = {
          host: @params[:host],
          port: @params[:port],
          base: @params[:base_dn],
          auth: {
            method: :simple,
            username: @params[:bind_username],
            password: @params[:bind_password],
          },
        }

        port = @params[:port] if @params[:port] && !@params[:port].zero?
        case @params[:protocol]
        when 'ldap'
          opts[:port] = port || 389
        when 'ldap_starttls'
          opts[:port] = port || 389
          opts[:encryption] = {method: :start_tls}
        when 'ldaps'
          opts[:port] = port || 636
          opts[:encryption] = {method: :simple_tls}
        else
          raise "invalid protcol: #{@params[:protocol]}"
        end

        if opts[:encryption] && !@params[:certificate_check]
          opts[:encryption][:tls_options] = {verify_mode: OpenSSL::SSL::VERIFY_NONE}
        end

        Net::LDAP.new(opts)
      end

      private def search_user_opts(name, base: @params[:user_searh_base_dn] || @params[:base_dn],
                                   scope: @params[:user_search_scope], filter: @params[:user_search_filter])
        opts = {}

        opts[:base] = base

        opts[:scope] =
          case scope
          when 'base' then Net::LDAP::SearchScope_BaseObject
          when 'one' then Net::LDAP::SearchScope_SingleLevel
          when 'sub' then Net::LDAP::SearchScope_WholeSubtree
          else raise 'Invalid scope'
          end

        common_filter =
          if filter
            Net::LDAP::Filter.construct(filter)
          else
            Net::LDAP::Filter.pres('objectClass')
          end

        opts[:filter] = common_filter &
                        Net::LDAP::Filter.eq(@params[:user_name_attr], name)

        opts
      end

      private def entry2userdata(entry)
        attrs = {}
        entry.each do |name, value|
          cmp_name = name.to_s.method(:casecmp?)
          next if self.class.hide_attrs.any?(&cmp_name)

          attrs[name.to_s] = if self.class.multi_attrs.any?(&cmp_name)
                               value.to_a
                             else
                               value.first
                             end
        end

        {
          name: entry.first(@params[:user_name_attr]),
          display_name: entry.first(@params[:user_display_name_attr]),
          email: entry.first(@params[:user_email_attr]),
          attrs: attrs,
        }
      end

      private def attribute_name(name)
        Net::LDAP::Entry.attribute_name(name)
      end
    end
  end
end
