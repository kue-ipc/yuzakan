require_relative 'ldap_password_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < LdapPasswordAdapter
      self.name = 'posix_ldap'
      self.label = 'Posix LDAP'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapPasswordAdapter.params + [
          {
            name: :user_dn_attr,
            default: 'uid',
            placeholder: 'uid',
          }, {
            name: :user_name_attr,
            default: 'uid',
            placeholder: 'uid',
          }, {
            name: :user_search_filter,
            description:
            'ユーザー検索を行うときのフィルターです。' \
            'LDAPの形式で指定します。' \
            '何も指定しない場合は(objectclass=posixAccount)になります。',
            default: '(objectclass=posixAccount)',
          }, {
            name: :group_name_attr,
            label: 'グループ名の属性',
            type: :string,
            default: 'cn',
            placeholder: 'cn',
          }, {
            name: :group_display_name_attr,
            label: 'グループ表示名の属性',
            type: :string,
            default: 'description;lang-ja',
            placeholder: 'description;lang-ja',
          }, {
            name: :group_search_base_dn,
            label: 'グループ検索のベースDN',
            description: 'グループ検索を行うときのベースです。' \
                         '指定しない場合はLDAPサーバーのベースから検索します。',
            type: :string,
            required: false,
            placeholder: 'ou=Groups',
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
            description:
        'ユーザー検索を行うときのフィルターです。' \
        'LDAPの形式で指定します。' \
        '何も指定しない場合は(objectclass=posixGroup)になります。',
            type: :string,
            default: '(objectclass=posixGroup)',
            required: false,
          },
        ], key: :name)
      self.multi_attrs = LdapPasswordAdapter.multi_attrs
      self.hide_attrs = LdapPasswordAdapter.hide_attrs

      def group_read(groupname)
        opts = search_group_opts(groupname)
        result = ldap.search(opts)
        entry2groupdata(result.first) if result && !result.empty?
      end

      def group_list
        generate_ldap.search(search_group_opts('*')).map do |group|
          group[@params[:group_name_attr]].first.downcase
        end
      end

      private def search_group_opts(name, filter: @params[:group_search_filter])
        search_opts(@params[:group_name_attr], name,
                    base: @params[:group_search_base_dn] || @params[:base_dn],
                    scope: @params[:group_search_scope],
                    filter: filter)
      end

      private def entry2groupdata(entry)
        {
          name: entry.first(@params[:group_name_attr]).downcase,
          display_name: entry.first(@params[:group_display_name_attr]),
        }
      end
    end
  end
end
