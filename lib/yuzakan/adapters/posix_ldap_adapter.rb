require_relative 'ldap_adapter'

module Yuzakan
  module Adapters
    class PosixLdapAdapter < LdapAdapter
      self.name = 'posix_ldap'
      self.label = 'Posix LDAP'
      self.version = '0.0.1'
      self.params = ha_merge(
        LdapAdapter.params + [
          {
            name: :user_name_attr,
            default: 'uid',
            placeholder: 'uid',
          }, {
            name: :user_search_filter,
            description: 'ユーザー検索を行うときのフィルターです。' \
                         'LDAPの形式で指定します。' \
                         '何も指定しない場合は(objectclass=posixAccount)になります。',
            default: '(objectclass=posixAccount)',
          }, {
            name: :group_search_filter,
            description: 'ユーザー検索を行うときのフィルターです。' \
                         'LDAPの形式で指定します。' \
                         '何も指定しない場合は(objectclass=posixGroup)になります。',
            default: '(objectclass=posixGroup)',
          }, {
            name: :create_user_object_classes,
            description: 'オブジェクトクラスをカンマ区切りで入力してください。' \
                         'posixAccount は自動的に追加されます。',
            default: 'account',
            placeholder: 'account',
          }, {
            name: :uid_min,
            label: 'UID番号の最小値',
            description: 'UID番号の最小値です。',
            type: :integer,
            default: 1000,
          }, {
            name: :uid_max,
            label: 'UID番号の最大値',
            description: 'UID番号の最大値です。',
            type: :integer,
            default: 60000,
          }, {
            name: :search_free_uid,
            label: 'UID番号の探索アルゴリズム',
            description: '空いているUID番号を探すアルゴリズムです。',
            type: :string,
            default: 'next',
            list: [
              {name: :random, label: '最小', value: 'min'},
              {name: :random, label: '次', value: 'next'},
              {name: :random, label: 'ランダム', value: 'random'},
            ],
          }, {
            name: :user_gid_nuber,
            label: 'ユーザーのGID番号',
            description: 'プライマリーグループが指定されなかった場合に設定されるユーザーのGID番号です。',
            type: :integer,
            default: 100,
          },
        ], key: :name)
      self.multi_attrs = LdapAdapter.multi_attrs
      self.hide_attrs = LdapAdapter.hide_attrs

      private def create_user_attributes(username, **userdata)
        attributes = super

        # object class
        attributes[attribute_name('objectClass')] << 'posixAccount'

        # uid number
        uid_number = search_free_uid
        attributes[attribute_name('uidNumber')] = convert_ldap_value(uid_number)

        # gid number
        gid_number =
          if userdata[:primary_group]
            get_gidnumber(userdata[:primary_group])
          else
            @params[:user_gid_number]
          end
        attributes[attribute_name('gidNumber')] = convert_ldap_value(gid_number)

        attributes
      end

      private def update_user_attributes(**userdata)
        attributes = super

        # gid number
        gid_number =
          if userdata[:primary_group]
            get_gidnumber(userdata[:primary_group])
          else
            @params[:user_gid_number]
          end
        attributes[attribute_name('gidNumber')] = convert_ldap_value(gid_number)

        attributes
      end

      # 空いているUID番号を探して返す。
      private def search_free_uid
        case @params[:search_free_uid]
        when 'min'
          searhc_free_uid_min
        when 'next'
          searhc_free_uid_next
        when 'random'
          searhc_free_uid_random
        else
          @logger.error "invalid search free id algoripthm: #{@params[:search_free_uid]}"
          raise 'UID検索アルゴリズムが不正です。'
        end
      end

      private def searhc_free_uid_random
        (@params[:uid_min]..@params[:uid_max]).to_a.shuffle.each do |num|
          return num unless posix_passwd_byuid_map.key?(num)
        end
        @logger.error 'There is no free UID numebr'
        raise '空いているUID番号がありません。'
      end

      private def searhc_free_uid_next
        next_num = posix_passwd_byuid_map.keys.max.succ
        if next_num > @params[:uid_max]
          @logger.warn 'UID numebr has reached max.'
          return searhc_free_uid_min
        elsif next_num < @params[:uid_min]
          @logger.warn 'UID numebr does not reach min.'
          next_num = @params[:uid_min]
        end
        next_num
      end

      private def searhc_free_uid_min
        (@params[:uid_min]..@params[:uid_max]).each do |num|
          return num unless posix_passwd_byuid_map.key?(num)
        end
        @logger.error 'There is no free UID numebr'
        raise '空いているUID番号がありません。'
      end

      private def get_gidnumber(groupname)
        group = get_group_entry(groupname)
        group['gidNumber']&.first&.to_i
      end

      private def get_primary_group(user)
        get_gidnumber_groups(user).first
      end

      private def get_memberof_groups(user)
        (get_gidnumber_groups(user) + get_memberuid_groups(user)).compact.uniq
      end

      private def get_gidnumber_groups(user)
        filter = Net::LDAP::Filter.eq('gidNumber', user.gidNumber.first)
        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_memberuid_groups(user)
        filter = Net::LDAP::Filter.eq('memberUid', user.uid.first)
        opts = search_group_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_member_users(group)
        (get_gidnumber_users(group) + get_memberuid_users(group)).uniq
      end

      private def get_gidnumber_users(group)
        filter = Net::LDAP::Filter.eq('gidNumber', group.gidNumber.first)
        opts = search_user_opts('*', filter: filter)
        ldap_search(opts).to_a
      end

      private def get_memberuid_users(group)
        group['memberUid'].map do |uid|
          filter = Net::LDAP::Filter.eq('uid', uid)
          opts = search_user_opts('*', filter: filter)
          ldap_search(opts).first
        end.compact
      end

      private def add_member(group, user)
        return false if group['memberUid']&.include?(user.uid.first)
        return false if user.gidNumber.first == group.gidNumber.first

        operations = [operation_add(:memberuid, user.uid.first)]
        ldap_modify(group.dn, operations)
      end

      private def remove_member(group, user)
        return false unless group['memberUid']&.incldue?(user.uid.first)

        operations = [operation_delete(:memberuid, user.uid.first)]
        ldap_modify(group.dn, operations)
      end

      # NIS互換
      private def posix_passwds
        @posix_passwds ||= ldap_search(search_user_opts('*')).map do |user|
          {
            name: user['uid'].first,
            passwd: 'x',
            uid: user['uidNumebr'].first.to_i,
            gid: user['gidNumebr'].first.to_i,
            gecos: user['gecos']&.first || '',
            dir: user['homeDirectory']&.first || '',
            shell: user['loginShell']&.first || '',
          }
        end
      end

      private def posix_groups
        @posix_groups ||= ldap_search(search_group_opts('*')).map do |group|
          {
            name: group['cn'].first,
            passwd: 'x',
            gid: group['gidNumebr'].first.to_i,
            mem: group['memberUid']&.to_a || [],
          }
        end
      end

      private def posix_passwd_byuid_map
        @posix_passwd_byuid_map ||= posix_passwds.to_h { |pw| [pw[:uid], pw] }
      end

      private def posix_passwd_byname_map
        @posix_passwd_byname_map ||= posix_passwds.to_h { |pw| [pw[:name], pw] }
      end

      private def posix_group_bygid_map
        @posix_group_bygid_map ||= postix_groups.to_h { |gr| [gr[:gid], gr] }
      end

      private def posix_group_byname_map
        @posix_group_byname_map ||= postix_groups.to_h { |gr| [gr[:name], gr] }
      end
    end
  end
end
