# frozen_string_literal: true

require 'securerandom'
require 'base64'
require 'digest'

require 'net/ldap'
require 'net/ldap/dn'

require_relative 'abstract_adapter'
require_relative 'abstract_adapter/adapter_error'
require_relative '../utils/ignore_case_string_set'

# パスワード変更について
# userPassword は {CRYPT}$6$%.16s をデフォルトする。

module Yuzakan
  module Adapters
    class LdapAdapter < AbstractAdapter
      class LdapAdapterError < Yuzakan::Adapters::AbstractAdapter::AdapterError
      end

      self.name = 'ldap'
      self.display_name = 'LDAP'
      self.version = '0.0.1'
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
          label: 'プロトコル/暗号化形式',
          description: 'LDAPサーバーにアクセスするプロトコルを指定します。',
          type: :string,
          default: 'ldaps',
          list: [
            {name: :ldap, label: 'LDAP(平文)', value: 'ldap', deprecated: true},
            {name: :ldap_starttls, label: 'LDAP+STARTTLS(暗号化)',
             value: 'ldap_starttls',},
            {name: :ldaps, label: 'LDAPS(暗号化)', value: 'ldaps'},
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
          description: 'LDAPのベースです。',
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
          name: :user_name_attr,
          label: 'ユーザー名の属性',
          type: :string,
          required: true,
          placeholder: 'cn, uid, name, etc...',
          description: 'ユーザーの検索時に使用されます。',
        }, {
          name: :user_display_name_attr,
          label: 'ユーザー表示名の属性',
          type: :string,
          required: false,
          placeholder: 'displayName, displayName;lang-ja, etc...',
          description: '設定しない場合は使われません。',
        }, {
          name: :user_email_attr,
          label: 'ユーザーメールの属性',
          type: :string,
          required: false,
          placeholder: 'mail, email, maildrop, etc...',
          description: '設定しない場合は使われません。',
        }, {
          name: :user_search_base_dn,
          label: 'ユーザー検索のベースDN',
          description: 'ユーザー検索を行うときのベースです。' \
                       '指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Users,dc=example,dc=jp',
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
          description: 'ユーザー検索を行うときのフィルターです。' \
                       'LDAPの形式で指定します。' \
                       '何も指定しない場合は(objectclass=*)になります。',
          type: :string,
          default: '(objectclass=*)',
          required: false,
        }, {
          name: :group_name_attr,
          label: 'グループ名の属性',
          type: :string,
          default: 'cn',
          placeholder: 'cn',
        }, {
          name: :group_name_suffix,
          label: 'グループ名のサフィックス',
          description: 'グループ名にサフィックスがある場合は自動的に追加・除去をします。',
          type: :string,
        }, {
          name: :group_display_name_attr,
          label: 'グループ表示名の属性',
          type: :string,
          default: 'description',
          placeholder: 'description',
        }, {
          name: :group_search_base_dn,
          label: 'グループ検索のベースDN',
          description: 'グループ検索を行うときのベースです。' \
                       '指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
          placeholder: 'ou=Groups,dc=example,dc=jp',
        }, {
          name: :group_search_scope,
          label: 'グループ検索のスコープ',
          description: 'グループ検索を行うときのスコープです。' \
                       '通常は sub を使用します。',
          type: :string,
          default: 'sub',
          list: [
            {name: :base, label: 'ベースのみ検索(base)', value: 'base'},
            {name: :one, label: 'ベース直下のみ検索(one)', value: 'one'},
            {name: :sub, label: 'ベース配下全て検索(sub)', value: 'sub'},
          ],
        }, {
          name: :group_search_filter,
          label: 'グループ検索のフィルター',
          description: 'ユーザー検索を行うときのフィルターです。' \
                       'LDAPの形式で指定します。' \
                       '何も指定しない場合は(objectclass=*)になります。',
          type: :string,
          default: '(objectclass=*)',
          required: false,
        }, {
          name: :password_scheme,
          label: 'パスワードのスキーム',
          description: 'パスワード設定時に使うスキームです。' \
                       '{CRYPT}はソルトフォーマットも選択してください。' \
                       '対応するスキームはLDAPサーバーの実装によります。',
          type: :string,
          required: true,
          default: '{CRYPT}',
          list: [
            {name: :cleartext, label: '{CLEARTEXT} 平文', value: '{CLEARTEXT}', deprecated: true},
            {name: :crypt, label: '{CRYPT} CRYPT', value: '{CRYPT}'},
            {name: :md5, label: '{MD5} MD5', value: '{MD5}', deprecated: true},
            {name: :sha, label: '{SHA} SHA-1', value: '{SHA}', deprecated: true},
            {name: :sha256, label: '{SHA256} SHA-256', value: '{SHA256}', deprecated: true},
            {name: :sha512, label: '{SHA512} SHA-512', value: '{SHA512}', deprecated: true},
            {name: :smd5, label: '{SMD5} ソルト付MD5', value: '{SMD5}', deprecated: true},
            {name: :ssha, label: '{SSHA} ソルト付SHA-1', value: '{SSHA}', deprecated: true},
            {name: :ssha256, label: '{SSHA256} ソルト付-SHA256', value: '{SSHA256}'},
            {name: :ssha512, label: '{SSHA512} ソルト付SHA-512', value: '{SSHA512}'},
            {name: :pbkdf2_sha1, label: '{PBKDF2-SHA1} PBKDF2 SHA-1', value: '{PBKDF2-SHA1}', deprecated: true},
            {name: :pbkdf2_sha256, label: '{PBKDF2-SHA256} PBKDF2 SHA256', value: '{PBKDF2-SHA256}'},
            {name: :pbkdf2_sha512, label: '{PBKDF2-SHA512} PBKDF2 SHA256', value: '{PBKDF2-SHA512}'},
          ],
        }, {
          name: :crypt_salt_format,
          label: 'CRYPTのソルトフォーマット',
          description: 'パスワードのスキームに{CRYPT}を使用している場合は、' \
                       '記載のフォーマットでソルト値が作成されます。' \
                       '対応する形式はサーバーのcryptの実装によります。',
          type: :string,
          default: '$6$%.16s',
          list: [
            {name: :des, label: 'DES', value: '%.2s', deprecated: true},
            {name: :md5, label: 'MD5', value: '$1$%.8s', deprecated: true},
            {name: :sha256, label: 'SHA256', value: '$5$%.16s'},
            {name: :sha512, label: 'SHA512', value: '$6$%.16s'},
          ],
        }, {
          name: :create_user_dn_attr,
          label: 'ユーザー作成時のDNの属性',
          type: :string,
          default: 'cn',
          placeholder: 'cn',
        }, {
          name: :create_user_ou_dn,
          label: 'ユーザー作成時のOUのDN',
          type: :string,
          default: 'ou=Users,dc=example,dc=jp',
          placeholder: 'ou=Users,dc=example,dc=jp',
        }, {
          name: :create_user_object_classes,
          label: 'ユーザー作成時のオブジェクトクラス',
          description: 'オブジェクトクラスをカンマ区切りで入力してください。',
          type: :string,
          default: 'inetOrgPerson,nsMemberOf',
          placeholder: 'inetOrgPerson,nsMemberOf',
        },
      ]

      class << self
        attr_accessor :multi_attrs, :hide_attrs
      end

      self.multi_attrs = Yuzakan::Utils::IgnoreCaseStringSet.new(%w[objectClass member memberOf])
      self.hide_attrs = Yuzakan::Utils::IgnoreCaseStringSet.new(%w[userPassword])

      group true

      def check
        opts = {
          base: @params[:base_dn],
          scope: Net::LDAP::SearchScope_BaseObject,
        }
        if ldap_search(opts).first
          true
        else
          false
        end
      rescue LdapAdatpterError
        @logger.warn 'LDAP check failed due to an error'
        false
      end

      def user_create(username, password = nil, **userdata)
        return nil if user_read(username)

        user = ldap_user_create(**userdata, username: username, passward: password)

        # パスワードは渡さない
        user = ldap_get(user.dn) if run_after_user_create(user, **userdata)

        user_entry_to_data(user)
      end

      private def ldap_user_create(**userdata)
        attributes = create_user_attributes(**userdata)

        dn_attr = @params[:create_user_dn_attr]
        attribute_name(@params[:create_user_dn_attr])
        dn = "#{dn_attr}=#{attributes[dn_attr.intern]},#{@params[:create_user_ou_dn]}"
        ldap_add(dn, attributes)

        ldap_get(dn)
      end

      private def run_after_user_create(user, primary_group: nil, groups: [], **userdata)
        changed = false

        # グループの追加
        [primary_group, *groups].compact.uniq.each do |groupname|
          group = ldap_group_read(groupname)
          next unless group

          changed = true if ldap_member_add(group, user)
        end

        changed
      end

      def user_read(username)
        user = ldap_user_read(username)
        return if user.nil?

        user_entry_to_data(user)
      end

      def user_update(username, **userdata)
        user = ldap_user_read(username)
        return if user.nil?
        return if user_entry_unmanageable?(user)

        attributes = update_user_attributes(**userdata)
        operations = update_operations(user, attributes)
        ldap_modify(user.dn, operations) unless operations.empty?

        run_after_user_update(username, **userdata)

        user_read(username)
      end

      private def run_after_user_update(username, **userdata)
        # プリマリーグループがあれば、無条件で追加する。
        member_add(userdata[:primary_group], username) if userdata[:primary_group]

        # グループの追加と削除
        return unless userdata[:groups]

        cur_list = user_group_list(username)
        new_list = [userdata[:primary_group], *userdata[:groups]].compact.uniq
        (new_list - cur_list).each do |groupname|
          member_add(groupname, username)
        end
        (cur_list - new_list).each do |groupname|
          member_remove(groupname, username)
        end
      end

      def user_delete(username)
        user = ldap_user_read(username)
        return if user.nil?
        return if user_entry_unmanageable?(user)

        data = user_entry_to_data(user)

        run_before_user_delete(username)

        ldap_delete(user.dn)

        data
      end

      private def run_before_user_delete(username)
        # do nothing
      end

      def user_auth(username, password)
        user = ldap_user_read(username)
        return false if user.nil?
        return false if user_entry_locked?(user)

        @logger.debug "LDAP bind: #{user.dn}"
        # 認証のbindには別のLDAPインスタンスを使用します。
        generate_ldap.bind(method: :simple, username: user.dn, password: password)
      end

      def user_change_password(username, password)
        user = ldap_user_read(username)
        return false if user.nil?
        return false if user_entry_unmanageable?(user)
        return false if user_entry_unmanageable?(user)

        ldap_modify(user.dn, change_password_operations(user, password, locked: user_entry_locked?(user)))
      end

      def user_lock(username)
        user = ldap_user_read(username)
        return false if user.nil?
        return false if user_entry_unmanageable?(user)

        # ロックが既にかかっていても変更を実施する
        ldap_modify(user.dn, lock_operations(user))
      end

      def user_unlock(username, password = nil)
        user = ldap_user_read(username)
        return false if user.nil?
        return false if user_entry_unmanageable?(user)
        return true if user_entry_locked?(user) && password.nil?

        # ロックが既に外れていても変更を実施する
        ldap_modify(user.dn, unlock_operations(user, password))
      end

      def user_list
        opts = search_user_opts('*')
        ldap_search(opts).map { |user| get_user_name(user) }
      end

      def user_search(query)
        filter = Net::LDAP::Filter.eq(@params[:user_name_attr], query)

        [:display_name, :email].each do |name|
          attr_name = @params["user_#{name}_attr".intern]
          filter |= Net::LDAP::Filter.eq(attr_name, query) if attr_name&.size&.positive?
        end

        opts = search_user_opts('*', filter: filter)
        ldap_search(opts).map { |user| get_user_name(user) }
      end

      def user_group_list(username)
        user = ldap_user_read(username)
        get_memberof_groups(user).map { |group| get_group_name(group) }
      end

      def group_read(groupname)
        group = ldap_group_read(groupname)
        group && group_entry_to_data(group)
      end

      def group_list
        opts = search_group_opts('*')
        ldap_search(opts).map { |group| get_group_name(group) }
      end

      def group_search(query)
        filter = Net::LDAP::Filter.eq(@params[:group_name_attr], query)

        [:display_name].each do |name|
          attr_name = @params["group_#{name}_attr".intern]
          filter |= Net::LDAP::Filter.eq(attr_name, query) if attr_name&.size&.positive?
        end

        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).map { |user| get_group_name(user) }
      end

      def member_list(groupname)
        group = ldap_group_read(groupname)
        return if group.nil?

        get_member_users(group).map { |user| get_user_name(user) }
      end

      def member_add(groupname, username)
        group = ldap_group_read(groupname)
        return if group.nil?

        user = ldap_user_read(username)
        return if user.nil?

        ldap_member_add(group, user)
      end

      def member_remove(groupname, username)
        group = ldap_group_read(groupname)
        return if group.nil?

        user = ldap_user_read(username)
        return if user.nil?

        remove_member(group, user)
      end

      ## プライベートメソッド

      # 値をLDAP上の値に変換する
      private def convert_ldap_value(value)
        case value
        when nil
          nil
        when true
          'TRUE'
        when false
          'FALSE'
        when String
          value
        when Integer
          value.to_s
        when Time
          value.utc.strftime('%Y%m%d%H%M%S.%1NZ')
        when Array
          value.map { |v| convert_ldap_value(v) }
        else
          raise LdapAdatperError, "unsupported value type: #{value.class}"
        end
      end

      private def create_user_attributes(username:, password: nil, display_name: nil, email: nil, **userdata)
        attributes = userdata[:attrs].transform_keys { |key| attribute_name(key) }
        attributes.transform_values! { |value| convert_ldap_value(value) }

        attributes[attribute_name('objectClass')] = @params[:create_user_object_classes].split(',').map(&:strip)

        attributes[attribute_name(@params[:create_user_dn_attr])] = username
        unless @params[:user_name_attr].casecmp?(@params[:create_user_dn_attr])
          attributes[attribute_name(@params[:user_name_attr])] = username
        end

        if @params[:user_display_name_attr]&.size&.positive? && display_name&.size&.positive?
          attributes[attribute_name(@params[:user_display_name_attr])] = display_name
        end
        if @params[:user_email_attr]&.size&.positive? && email&.size&.positive?
          attributes[attribute_name(@params[:user_email_attr])] = email
        end

        attributes.merge!(create_user_password_attributes(password)) if password

        attributes
      end

      private def create_user_password_attributes(password)
        {attribute_name('userPassword') => generate_password(password)}
      end

      private def update_user_attributes(**userdata)
        attributes = userdata[:attrs].transform_keys { |key| attribute_name(key) }
        attributes.transform_values! { |value| convert_ldap_value(value) }

        [:display_name, :email].each do |name|
          attr_name = @params["user_#{name}_attr".intern]
          if attr_name&.size&.positive? && (userdata[name])
            attributes[attribute_name(@params["user_#{name}_attr".intern])] = userdata[name]
          end
        end

        attributes
      end

      private def update_operations(entry, attributes)
        ops = []
        attributes.each do |name, value|
          entry_values = entry[name]
          if entry_values.nil? || entry_values.empty?
            ops << operation_add(name, value) if value
            next
          end

          if value.nil?
            ops << operation_delete(name)
            next
          end

          value_same =
            if value.is_a?(Array)
              entry_values.sort == value.sort
            else
              entry_values == [value]
            end
          ops << operation_replace(name, value) unless value_same
        end
        ops
      end

      private def generate_operation(operator, name, value = nil)
        raise LdapAdatperError, "invalid operator: #{operator}" unless [:add, :replace, :delete].include?(operator)

        [operator, name, value]
      end

      private def operation_add(name, value)
        generate_operation(:add, name, value)
      end

      private def operation_replace(name, value)
        generate_operation(:replace, name, value)
      end

      private def operation_delete(name, value = nil)
        generate_operation(:delete, name, value)
      end

      private def operation_add_or_replace(name, value, entry)
        if entry.first(name).nil?
          operation_add(name, value)
        else
          operation_replace(name, value)
        end
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
          raise LdapAdatperError, "invalid protcol: #{@params[:protocol]}"
        end

        if opts[:encryption] && !@params[:certificate_check]
          opts[:encryption][:tls_options] =
            {verify_mode: OpenSSL::SSL::VERIFY_NONE}
        end

        Net::LDAP.new(opts)
      end

      private def scope_in?(dn, base:, scope:)
        dn_arr = dn.to_a.map(&:downcase)
        base_arr = base.to_a.map(&:downcase)
        return false unless dn_arr[-base_arr.size, base_arr.size] == base_arr

        case scope
        when Net::LDAP::SearchScope_BaseObject
          dn_arr.size == base_arr.size
        when Net::LDAP::SearchScope_SingleLevel
          dn_arr.size == base_aget_dnuserrr.size + 2
        when Net::LDAP::SearchScope_WholeSubtree
          true
        end
      end

      private def generate_filter(filter)
        if filter&.size&.positive?
          Net::LDAP::Filter.construct(filter)
        else
          Net::LDAP::Filter.pres('objectClass')
        end
      end

      private def generate_scope(scope)
        case scope
        when 'base' then Net::LDAP::SearchScope_BaseObject
        when 'one' then Net::LDAP::SearchScope_SingleLevel
        when 'sub' then Net::LDAP::SearchScope_WholeSubtree
        else raise LdapAdapterError, 'Invalid scope'
        end
      end

      private def user_search_filter
        @user_search_filter ||= generate_filter(@params[:user_search_filter])
      end

      private def group_search_filter
        @group_search_filter ||= generate_filter(@params[:group_search_filter])
      end

      private def user_search_scope
        @user_search_scope ||= generate_scope(@params[:user_search_scope])
      end

      private def group_search_scope
        @group_search_scope ||= generate_scope(@params[:group_search_scope])
      end

      private def user_search_base_dn
        @user_search_base_dn ||=
          Net::LDAP::DN.new(@params[:user_search_base_dn] || @params[:base_dn])
      end

      private def group_search_base_dn
        @group_search_base_dn ||=
          Net::LDAP::DN.new(@params[:group_search_base_dn] || @params[:base_dn])
      end

      private def search_user_opts(name,
                                   base: user_search_base_dn,
                                   scope: user_search_scope,
                                   filter: nil)
        filter = Net::LDAP::Filter.construct(filter) if filter.is_a?(String)

        if filter
          filter &= user_search_filter
        else
          filter = user_search_filter
        end

        {
          base: base,
          scope: scope,
          filter: filter &
                  Net::LDAP::Filter.eq(@params[:user_name_attr], name),
        }
      end

      private def search_group_opts(name,
                                    base: group_search_base_dn,
                                    scope: user_search_scope,
                                    filter: nil)
        filter = Net::LDAP::Filter.construct(filter) if filter.is_a?(String)

        if filter
          filter &= group_search_filter
        else
          filter = group_search_filter
        end

        {
          base: base,
          scope: scope,
          filter: filter &
                  Net::LDAP::Filter.eq(@params[:group_name_attr], name),
        }
      end

      private def user_entry_to_data(user)
        name = get_user_name(user)

        attrs = {}
        user.each do |key, value|
          key = key.downcase.to_s
          next if self.class.hide_attrs.include?(key)

          attrs[key] =
            if self.class.multi_attrs.include?(key)
              value.to_a
            else
              value.first
            end
        end

        primary_group = get_primary_group(user)&.then { |group| get_group_name(group) }
        groups = get_memberof_groups(user).map { |group| get_group_name(group) }

        {
          username: name,
          display_name: @params[:user_display_name_attr] && user.first(@params[:user_display_name_attr]),
          email: @params[:user_email_attr] && user.first(@params[:user_email_attr])&.downcase,
          locked: user_entry_locked?(user),
          unmanageable: user_entry_unmanageable?(user),
          mfa: user_entry_mfa?(user),
          primary_group: primary_group,
          groups: groups,
          attrs: attrs,
        }
      end

      private def group_entry_to_data(group)
        name = get_group_name(group)

        # 属性は渡さない
        # attrs = {}
        # group.each do |key, value|
        #   key = key.downcase.to_s
        #   next if self.class.hide_attrs.include?(key)

        #   attrs[key] =
        #     if self.class.multi_attrs.include?(key)
        #       value.to_a
        #     else
        #       value.first
        #     end
        # end

        {
          groupname: name,
          display_name: group.first(@params[:group_display_name_attr]),
          # attrs: attrs,
        }
      end

      # 属性名を正規化する
      private def attribute_name(name)
        Net::LDAP::Entry.attribute_name(name)
      end

      private def ldap_user_read(username)
        opts = search_user_opts(username)
        ldap_search(opts).first
      end

      private def ldap_group_read(groupname)
        groupname += @params[:group_name_suffix] if @params[:group_name_suffix]&.size&.positive?
        opts = search_group_opts(groupname)
        ldap_search(opts).first
      end

      private def get_user_name(user)
        user.first(@params[:user_name_attr]).downcase
      end

      private def get_group_name(group)
        name = group.first(@params[:group_name_attr]).downcase
        if @params[:group_name_suffix]&.size&.positive? &&
           name.delete_suffix!(@params[:group_name_suffix].downcase).nil?
          @logger.warn "no suffix group name: #{name}"
        end
        name
      end

      private def get_primary_group(_user)
        nil
      end

      private def get_memberof_groups(user)
        filter = Net::LDAP::Filter.eq('member', user.dn)
        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_member_users(group)
        filter = Net::LDAP::Filter.eq('memberOf', group.dn)
        opts = search_user_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def ldap_member_add(group, user)
        return false if user['memberOf'].include?(group.dn)

        operations = [operation_add(:member, user.dn)]
        ldap_modify(group.dn, operations)
      end

      private def remove_member(group, user)
        return false unless user['memberOf'].include?(group.dn)

        operations = [operation_delete(:member, user.dn)]
        ldap_modify(group.dn, operations)
      end

      private def value_to_str(value)
        case value
        when String
          value
        when true
          'TRUE'
        when false
          'FALSE'
        when nil
          ''
        when Integer
          value.to_s
        when Time
          value.utc.strftime('%Y%m%d%H%M%SZ')
        when Array
          value.map { |v| value_to_str(v) }
        else
          @logger.warn "Unknown value type: #{value.class.name}"
          value.to_s
        end
      end

      # LDAPへのアクセス

      # LDAP操作後のフック
      private def after_ldap_action(action, result)
        return if result

        ldap_error_message = ldap.get_operation_result.error_message
        @logger.error "LDAP #{action} error: #{ldap_error_message}"
        raise LdapAdapterError, ldap_error_message
      end

      private def ldap_get(dn)
        opts = {base: dn, scope: Net::LDAP::SearchScope_BaseObject}
        ldap_search(opts).first
      end

      private def ldap_search(opts)
        @logger.debug "LDAP search: #{opts}"
        result = ldap.search(opts)
        after_ldap_action(:search, result)
        result
      end

      private def ldap_add(dn, attributes)
        @logger.debug "LDAP add: #{dn}"
        str_attrs = attributes.transform_values { |value| value_to_str(value) }
        result = ldap.add({dn: dn, attributes: str_attrs})
        after_ldap_action(:add, result)
        result
      end

      private def ldap_modify(dn, operations)
        @logger.debug "LDAP modify: #{dn}"
        result = ldap.modify({dn: dn, operations: operations})
        after_ldap_action(:modify, result)
        result
      end

      private def ldap_delete(dn)
        @logger.debug "LDAP delete: #{dn}"
        result = ldap.delete({dn: dn})
        after_ldap_action(:delete, result)
        result
      end

      private def ldap_rename(olddn, newrdn)
        @logger.debug "LDAP rename: #{oldnd} -> #{newrdn}"
        result = ldap.rename({olddn: olddn, newrdn: newrdn})
        after_ldap_action(:rename, result)
        result
      end

      private def user_entry_locked?(user)
        password = user.first('userPassword')
        return false if password.nil?

        password.start_with?(/\{[\w-]+\}!/)
      end

      private def user_entry_unmanageable?(user)
        @params[:bind_username].casecmp?(user.dn)
      end

      private def user_entry_mfa?(_user)
        false
      end

      private def change_password_operations(user, password, locked: false)
        user_password = generate_password(password)
        user_password = lock_password(user_password) if locked

        operations = []
        operations << if user.first('userPassword')
                        operation_replace('userPassword', user_password)
                      else
                        operation_add('userPassword', user_password)
                      end
        operations
      end

      private def lock_operations(user)
        old_password = user.frist('userPassword')
        if old_password
          new_password = lock_password(old_password)
          [operation_replace('userPassword', new_password)]
        else
          # 何もしない
          []
        end
      end

      private def unlock_operations(user, password = nil)
        if password
          change_password_operations(user, password)
        else
          old_password = user.first('userPassword')
          if old_password
            new_password = unlock_password(old_password)
            [operation_replace('userPassword', new_password)]
          else
            # 何もしない
            []
          end
        end
      end

      # https://trac.tools.ietf.org/id/draft-stroeder-hashed-userpassword-values-00.html
      private def generate_password(password)
        case @params[:password_scheme].upcase
        when '{CLEARTEXT}'
          password
        when '{CRYPT}'
          "{CRYPT}#{generate_crypt_password(password)}"
        when '{MD5}'
          "{MD5}#{Base64.strict_encode64(Digest::MD5.digest(password))}"
        when '{SHA}'
          "{SHA}#{Base64.strict_encode64(Digest::SHA1.digest(password))}"
        when '{SHA256}'
          "{SHA256}#{Base64.strict_encode64(Digest::SHA256.digest(password))}"
        when '{SHA512}'
          "{SHA512}#{Base64.strict_encode64(Digest::SHA512.digest(password))}"
        when '{SMD5}'
          salt = SecureRandom.random_bytes(8)
          "{SMD5}#{Base64.strict_encode64(Digest::MD5.digest(password + salt) + salt)}"
        when '{SSHA}'
          salt = SecureRandom.random_bytes(8)
          "{SSHA}#{Base64.strict_encode64(Digest::SHA1.digest(password + salt) + salt)}"
        when '{SSHA256}'
          salt = SecureRandom.random_bytes(8)
          "{SSHA256}#{Base64.strict_encode64(Digest::SHA256.digest(password + salt) + salt)}"
        when '{SSHA512}'
          salt = SecureRandom.random_bytes(8)
          "{SSHA512}#{Base64.strict_encode64(Digest::SHA512.digest(password + salt) + salt)}"
        else
          # TODO: PBKDF2
          raise NotImplementedError
        end
      end

      private def generate_crypt_password(password, format: @params[:crypt_salt_format])
        # 16 [./0-9A-Za-z] chars
        salt = SecureRandom.base64(12).tr('+', '.')
        password.crypt(format % salt)
      end

      private def lock_password(str)
        if (m = /\A\{([\w-]+)\}(.*)\z/.match(str))
          scheme = m[1]
          value = m[2]
          if value.start_with?('!')
            # 既にロックされているため変更しない
            str
          else
            "{#{scheme}}!#{value}"
          end
        else
          @logger.warn('cleartext password')
          # CLEARTEXT is dummy scheme
          "{CLEARTEXT}!#{str}"
        end
      end

      private def unlock_password(str)
        if (m = /\A\{([\w-]+)\}!*([^!].*)\z/.match(str))
          scheme = m[1]
          value = m[2]
          if scheme.empty? || scheme == 'CLEARTEXT'
            @logger.warn('cleartext password')
            value
          else
            "{#{scheme}}#{value}"
          end
        else
          @logger.warn('cleartext password')
          str
        end
      end
    end
  end
end
