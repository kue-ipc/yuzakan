require 'set'

require 'net/ldap'
require 'net/ldap/dn'

require_relative 'abstract_adapter'
require_relative '../utils/ignore_case_string_set'

module Yuzakan
  module Adapters
    class LdapAdapter < AbstractAdapter
      class Error < StandardError
      end

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
            {name: :ldap_starttls, label: 'LDAP+STARTTLS(暗合)',
             value: 'ldap_starttls',},
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
          default: 'cn',
          placeholder: 'cn',
        }, {
          name: :user_display_name_attr,
          label: 'ユーザー表示名の属性',
          type: :string,
          default: 'displayName',
          placeholder: 'displayName',
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
        },
      ]

      class << self
        attr_accessor :multi_attrs, :hide_attrs
      end

      self.multi_attrs = Yuzakan::Utils::IgnoreCaseStringSet.new(%w[objectClass member memberOf])
      self.hide_attrs = Yuzakan::Utils::IgnoreCaseStringSet.new

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
      rescue Error
        @logger.warn 'LDAP check failed due to an error'
        false
      end

      def user_create(username, password = nil, **attrs)
        return nil if user_read(username)

        user_data = attrs.filter do |key, _|
                      key.is_a?(String)
                    end.transform_keys { |key| attribute_name(key) }
        user_data[attribute_name(@params[:user_name_attr])] = attrs[:username]
        if attrs[:display_name]
          user_data[attribute_name(@params[:user_display_name_attr])] =
            attrs[:display_name]
        end
        if attrs[:email]
          user_data[attribute_name(@params[:user_email_attr])] =
            attrs[:email]
        end

        dn = @params[:user_dn_attr] + '=' +
             ldap_attrs[@params[:user_dn_attr].intern] + ',' +
             @params[:user_base]

        ldap_add({dn: dn, attributes: user_data})

        user_change_password(username, password) if password

        user_read(username)
      end

      def user_read(username)
        entry = get_user_entry(username)
        entry && entry2userdata(entry)
      end

      def user_update(username, **attrs)
        raise NotImplementedError
      end

      def user_delete(username)
        raise NotImplementedError
      end

      def user_auth(username, password)
        opts_with_password = search_user_opts(username).merge(password: password)
        @logger.debug "ldap auth: #{opts_with_password}"
        # bind_as is re bind, so DON'T USE `ldap`
        generate_ldap.bind_as(opts_with_password)
      end

      def user_change_password(username, password)
        user = get_user_entry(username)
        return nil unless user

        operations = change_password_operations(password)
        ldap_modify(dn: user.dn, operations: operations)
      end

      def user_list
        opts = search_user_opts('*')
        ldap_search(opts).map { |user| get_user_name(user) }
      end

      def user_search(query)
        filter =
          Net::LDAP::Filter.eq(@params[:user_name_attr], query) |
          Net::LDAP::Filter.eq(@params[:user_display_name_attr], query) |
          Net::LDAP::Filter.eq(@params[:user_email_attr], query)

        filter &= Net::LDAP::Filter.construct(@params[:user_search_filter]) if @params[:user_search_filter]

        opts = search_user_opts('*', filter: filter)
        ldap_search(opts).map { |user| get_user_name(user) }
      end

      def user_gorup_list(username)
        user = get_user_entry(username)
        get_memberof_groups(user).map { |group| get_group_name(group) }
      end

      def group_read(groupname)
        gorup = get_group_entry(groupname)
        gorup && entry2groupdata(gorup)
      end

      def group_list
        opts = search_group_opts('*')
        ldap_search(opts).map { |group| get_group_name(group) }
      end

      def member_list(groupname)
        gorup = get_group_entry(groupname)
        return if entry.nil?

        get_member_users(gorup).map { |user| get_user_name(user) }
      end

      def member_add(groupname, _username)
        group = get_group_entry(groupname)
        return if gorup.nil?

        user = get_user_entry(user)
        return if user.nil?

        add_member(group, user)
      end

      def member_remove(groupname, _username)
        group = get_group_entry(groupname)
        return if gorup.nil?

        user = get_user_entry(user)
        return if user.nil?

        remove_member(group, user)
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
          opts[:encryption][:tls_options] =
            {verify_mode: OpenSSL::SSL::VERIFY_NONE}
        end

        Net::LDAP.new(opts)
      end

      private def scope_in?(dn, base:, scope:)
        dn_arr = dn.to_a.map(&:downcase)
        base_arr = dn.to_a.map(&:downcase)
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

      private def get_user_dn(user_dn)
        user_dn = Net::LDAP::DN.new(user_dn) if user_dn.is_a?(String)
        unless scope_in?(user_dn, base: user_search_base_dn,
                                  scope: user_search_scope)
          return nil
        end

        opts = search_user_opts('*', base: user_dn,
                                     scope: Net::LDAP::SearchScope_BaseObject)
        ldap_search(opts).first
      end

      private def get_group_dn(group_dn)
        group_dn = Net::LDAP::DN.new(group_dn) if group_dn.is_a?(String)
        unless scope_in?(group_dn, base: group_search_base_dn,
                                   scope: group_search_scope)
          return nil
        end

        opts = search_group_opts('*', base: group_dn,
                                      scope: Net::LDAP::SearchScope_BaseObject)
        @logger.degbu "ldap search: #{opts}"
        ldap_search(opts).first
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
        else raise 'Invalid scope'
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

      private def entry2userdata(entry)
        name = get_user_name(entry)

        attrs = {}
        entry.each do |key, value|
          key = key.downcase.to_s
          next if self.class.hide_attrs.include?(key)

          attrs[key] =
            if self.class.multi_attrs.include?(key)
              value.to_a
            else
              value.first
            end
        end

        {
          name: name,
          display_name: entry.first(@params[:user_display_name_attr]),
          email: entry.first(@params[:user_email_attr])&.downcase,
          attrs: attrs,
          groups: groups,
        }
      end

      private def entry2groupdata(entry)
        name = get_group_name(entry)

        attrs = {}
        entry.each do |key, value|
          key = key.downcase.to_s
          next if self.class.hide_attrs.include?(key)

          attrs[key] =
            if self.class.multi_attrs.include?(key)
              value.to_a
            else
              value.first
            end
        end

        {
          name: name,
          display_name: entry.first(@params[:group_display_name_attr]),
          attrs: attrs,
        }
      end

      private def attribute_name(name)
        Net::LDAP::Entry.attribute_name(name)
      end

      private def get_user_entry(username)
        opts = search_user_opts(username)
        ldap_search(opts).first
      end

      private def get_group_entry(groupname)
        groupname += @params[:group_name_suffix] if @params[:group_name_suffix]&.size&.positive?
        opts = search_group_opts(groupname)
        ldap_searh(opts).first
      end

      private def get_user_name(user_entry)
        user_entry.first(@params[:user_name_attr]).downcase
      end

      private def get_group_name(group_entry)
        name = group_entry.first(@params[:group_name_attr]).downcase
        if @params[:group_name_suffix]&.size&.positive? &&
           name.delete_suffix!(@params[:group_name_suffix].downcase).nil?
          @logger.warn "no suffix group name: #{name}"
        end
        name
      end

      private def get_memberof_groups(user_entry)
        filter = Net::LDAP::Filter.eq('member', user_entry.dn)
        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_member_users(group_entry)
        filter = Net::LDAP::Filter.eq('memberOf', group_entry.dn)
        opts = search_user_opts('*', filter: filter)
        ldapSsearch(opts).to_a
      end

      private def add_member(group_entry, user_entry)
        return false if user_entry.memberof.include?(group_entry.dn)

        operations = [generate_operation_add(:member, user_entry.dn)]
        ldap_modify(dn: group_entry.dn, operations: operations)
      end

      private def remove_member(group_entry, user_entry)
        return false if user_entry.memberof.exclude?(group_entry.dn)

        operations = [generate_operation_delete(:member, user_entry.dn)]
        ldap_modify(dn: group_entry.dn, operations: operations)
      end

      private def ldap_search(opts)
        @logger.debug "LDAP search: #{opts}"
        result = ldap.search(primary_opts)
        if result.nil?
          @logger.error "LDAP search error: #{ldap.get_operation_result.error_message}"
          raise Error, ldap.get_operation_result.error_message
        end
        result
      end

      private def ldap_add(dn, attributes)
        @logger.debug "LDAP add: #{dn}"
        result = ldap.add({dn: dn, attributes: attributes})
        unless result
          @logger.error "LDAP add error: #{ldap.get_operation_result.error_message}"
          raise Error, ldap.get_operation_result.error_message
        end

        result
      end

      private def ldap_modify(dn, operations)
        @logger.debug "LDAP modify: #{dn}"
        result = ldap.modify({dn: dn, operations: operations})
        unless result
          @logger.error "LDAP modify error: #{ldap.get_operation_result.error_message}"
          raise Error, ldap.get_operation_result.error_message
        end

        result
      end

      private def ldap_delete(dn)
        @logger.debug "LDAP delete: #{dn}"
        result = ldap.delete({dn: dn})
        unless result
          @logger.error "LDAP delete error: #{ldap.get_operation_result.error_message}"
          raise Error, ldap.get_operation_result.error_message
        end

        result
      end
    end
  end
end
