# frozen_string_literal: true

require "etc"

module Yuzakan
  module Adapters
    # rubocop: disable Metrics/ClassLength
    class PosixLdap < Ldap
      self.name = "posix_ldap"
      self.display_name = "Posix LDAP"
      self.version = "0.0.1"
      self.params = ha_merge(
        Ldap.params + [
          {
            name: :user_name_attr,
            default: "uid",
            placeholder: "uid",
          }, {
            name: :user_search_filter,
            description: "ユーザー検索を行うときのフィルターです。" \
                         "LDAPの形式で指定します。" \
                         "何も指定しない場合は(objectclass=posixAccount)になります。",
            default: "(objectclass=posixAccount)",
          }, {
            name: :group_search_filter,
            description: "ユーザー検索を行うときのフィルターです。" \
                         "LDAPの形式で指定します。" \
                         "何も指定しない場合は(objectclass=posixGroup)になります。",
            default: "(objectclass=posixGroup)",
          }, {
            name: :create_user_object_classes,
            description: "オブジェクトクラスをカンマ区切りで入力してください。" \
                         "posixAccount は自動的に追加されます。",
            default: "account",
            placeholder: "account",
          }, {
            name: :shadow_account,
            label: "shadowAccountの有効化",
            description: "オブジェクトクラスにshadowAccountを追加し、最終変更日が記録するようにします。",
            type: :boolean,
            default: true,
          }, {
            name: :uid_min,
            label: "UID番号の最小値",
            description: "UID番号の最小値です。",
            type: :integer,
            default: 1000,
          }, {
            name: :uid_max,
            label: "UID番号の最大値",
            description: "UID番号の最大値です。",
            type: :integer,
            default: 60000,
          }, {
            name: :search_free_uid,
            label: "UID番号の探索アルゴリズム",
            description: "空いているUID番号を探すアルゴリズムです。",
            type: :string,
            default: "next",
            list: [
              {name: :min, label: "最小", value: "min"},
              {name: :next, label: "次", value: "next"},
              {name: :random, label: "ランダム", value: "random"},
            ],
          }, {
            name: :user_gid_number,
            label: "ユーザーのGID番号",
            description: "プライマリーグループが指定されなかった場合に設定されるユーザーのGID番号です。",
            type: :integer,
            default: 100,
          },
        ], key: :name)
      self.multi_attrs = Ldap.multi_attrs
      self.hide_attrs = Ldap.hide_attrs

      group :primary

      # override
      # プライマリーグループはいれない
      private def ldap_user_group_list(user)
        get_memberuid_groups(user)
      end

      # override
      private def ldap_member_add(group, user)
        return false if group["memberUid"]&.include?(user.uid.first)
        return false if user.gidNumber.first == group.gidNumber.first

        operations = [operation_add(:memberuid, user.uid.first)]
        ldap_modify(group.dn, operations)
      end

      # override
      private def ldap_member_remove(group, user)
        return false unless group["memberUid"]&.include?(user.uid.first)

        operations = [operation_delete(:memberuid, user.uid.first)]
        ldap_modify(group.dn, operations)
      end

      # override
      private def run_after_user_update(user, **userdata)
        changed = super

        # グループを管理しない場合は何もしない。
        return change unless has_group?

        # プライマリーグループは通常のメンバーから削除する
        ldap_primary_group(user)&.then do |group|
          changed = true if ldap_member_remove(group, user)
        end

        changed
      end

      # override
      private def run_before_user_delete(user)
        changed = super

        # グループを管理しない場合は何もしない。
        return change unless has_group?

        # 通常のメンバーのみ削除する
        get_memberuid_groups(user).each do |group|
          changed = true if ldap_member_remove(group, user)
        end
      end

      # override
      private def create_user_attributes(primary_group: nil, **userdata)
        attributes = super

        # object class
        attributes[attribute_name("objectClass")] << "posixAccount"
        attributes[attribute_name("objectClass")] << "shadowAccount" if @params[:shadow_account]

        # uid number
        unless attributes.key?(attribute_name("uidNumber"))
          uid_number = search_free_uid
          attributes[attribute_name("uidNumber")] =
            convert_ldap_value(uid_number)
        end

        # gid number
        unless attributes.key?(attribute_name("gidNumber"))
          gid_number =
            if has_group?
              (primary_group && get_gidnumber(primary_group)) || @params[:user_gid_number]
            else
              @params[:user_gid_number]
            end
          attributes[attribute_name("gidNumber")] =
            convert_ldap_value(gid_number)
        end

        attributes
      end

      # override
      private def update_user_attributes(**userdata)
        attributes = super

        # グループを管理しない場合はスキップ
        return attributes unless has_group?

        # gid number
        if userdata[:primary_group]
          gid_number = get_gidnumber(userdata[:primary_group])
          attributes[attribute_name("gidNumber")] =
            convert_ldap_value(gid_number)
        end

        attributes
      end

      # override
      private def change_password_operations(user, password, locked: false)
        operations = super
        if @params[:shadow_account] && user["objectClass"].include?("shadowAccount")
          epoch_date = Time.now.to_i / 86400 # 86400 = 24 * 60 * 60
          operations << if user.first("shadowLastChange")
                          operation_replace("shadowLastChange", epoch_date.to_s)
                        else
                          operation_add("shadowLastChange", epoch_date.to_s)
                        end
        end
        operations
      end

      # override
      private def ldap_primary_group(user)
        get_gidnumber_groups(user).first
      end

      # override
      private def ldap_member_list(group)
        (get_gidnumber_users(group) + get_memberuid_users(group)).uniq
      end

      # override
      private def after_ldap_action(action, result)
        super
        # search以外はキャッシュを削除する。
        posix_cache_clear if action != :search
      end

      # 空いているUID番号を探して返す。
      private def search_free_uid
        case @params[:search_free_uid].intern
        when :min
          searhc_free_uid_min
        when :next
          searhc_free_uid_next
        when :random
          searhc_free_uid_random
        else
          @logger.error "invalid search free id algoripthm: #{@params[:search_free_uid]}"
          raise "UID検索アルゴリズムが不正です。"
        end
      end

      # 空いているUID番号のうち、一番小さい番号を取り出します。
      private def searhc_free_uid_min
        (@params[:uid_min]..@params[:uid_max]).each do |num|
          return num unless posix_passwd_byuid_map.key?(num)
        end
        @logger.error "There is no free UID numebr"
        raise "空いているUID番号がありません。"
      end

      # 使用されている最大の番号の次の番号を取り出します。
      # ただし、最大に達している場合は、一番小さい番号を取りします。
      private def searhc_free_uid_next
        next_num = posix_passwd_byuid_map.keys.max.succ
        if next_num > @params[:uid_max]
          @logger.warn "The highest UID numebr has reached max."
          return searhc_free_uid_min
        elsif next_num < @params[:uid_min]
          @logger.warn "The highest UID numebr is less than min."
          next_num = @params[:uid_min]
        end
        next_num
      end

      # ランダムに空いている番号を探します。
      private def searhc_free_uid_random
        (@params[:uid_min]..@params[:uid_max]).to_a.shuffle.each do |num|
          return num unless posix_passwd_byuid_map.key?(num)
        end
        @logger.error "There is no free UID numebr"
        raise "空いているUID番号がありません。"
      end

      # NIS互換属性からの各情報

      private def get_uidnumber(username)
        user = ldap_user_read(username)
        user.first("uidNumber")&.to_i
      end

      private def get_gidnumber(groupname)
        group = ldap_group_read(groupname)
        group.first("gidNumber")&.to_i
      end

      private def get_gidnumber_groups(user)
        filter = Net::LDAP::Filter.eq("gidNumber", user.gidNumber.first)
        opts = search_group_opts("*", filter: filter)
        ldap_search(opts).to_a
      end

      private def get_memberuid_groups(user)
        filter = Net::LDAP::Filter.eq("memberUid", user.uid.first)
        opts = search_group_opts("*", filter: filter)
        ldap_search(opts).to_a
      end

      private def get_gidnumber_users(group)
        filter = Net::LDAP::Filter.eq("gidNumber", group.gidNumber.first)
        opts = search_user_opts("*", filter: filter)
        ldap_search(opts).to_a
      end

      private def get_memberuid_users(group)
        group["memberUid"].map do |uid|
          filter = Net::LDAP::Filter.eq("uid", uid)
          opts = search_user_opts("*", filter: filter)
          ldap_search(opts).first
        end.compact
      end

      # NIS互換属性からのetc情報
      private def posix_cache_clear
        @posix_passwds = nil
        @posix_groups = nil
        @posix_passwd_byuid_map = nil
        @posix_passwd_byname_map = nil
        @posix_group_bygid_map = nil
        @posix_group_byname_map = nil
      end

      private def posix_passwds
        @posix_passwds ||= ldap_search(search_user_opts("*")).map do |user|
          get_posix_passwd(user)
        end
      end

      private def get_posix_passwd(user)
        passwd_args = Etc::Passwd.members.map do |name|
          case name
          when :name then user.first("uid")
          when :passwd then "x"
          when :uid then user.first("uidNumber").to_i
          when :gid then user.first("gidNumber").to_i
          when :gecos then user.first("gecos") || ""
          when :dir then user.first("homeDirectory") || ""
          when :shell then user.first("loginShell") || ""
          end
        end
        Etc::Passwd.new(*passwd_args)
      end

      private def posix_groups
        @posix_groups ||= ldap_search(search_group_opts("*")).map do |group|
          get_posix_group(group)
        end
      end

      private def get_posix_group(group)
        group_args = Etc::Group.members.map do |name|
          case name
          when :name
            group.first("cn")
          when :passwd
            "x"
          when :gid
            group.first("gidNumber").to_i
          when :mem
            group["memberUid"].to_a || []
          end
        end
        Etc::Group.new(*group_args)
      end

      private def posix_passwd_byuid_map
        @posix_passwd_byuid_map ||= posix_passwds.to_h { |pw| [pw.uid, pw] }
      end

      private def posix_passwd_byname_map
        @posix_passwd_byname_map ||= posix_passwds.to_h { |pw| [pw.name, pw] }
      end

      private def posix_group_bygid_map
        @posix_group_bygid_map ||= posix_groups.to_h { |gr| [gr.gid, gr] }
      end

      private def posix_group_byname_map
        @posix_group_byname_map ||= posix_groups.to_h { |gr| [gr.name, gr] }
      end
    end
    # rubocop: enable Metrics/ClassLength
  end
end
