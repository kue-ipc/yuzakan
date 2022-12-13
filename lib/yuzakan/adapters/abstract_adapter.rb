# adapter
#
# initialize(params)
# check -> true or false
#
# userdata:
#   usnername: String = username
#   display_name: String = display name
#   email: String = mail address
#   locked: ?bool
#   unmanageable: ?bool
#   mfa: ?bool
#   primary_group: ?String
#   groups: Array[String]
#   attrs: Hash = {key: value, ...}
#
# groupdate:
#   groupname: String = groupname
#   dislay_name: String = display name
#   x disabled: ?bool
#   x unmanageable: ?bool
#   x attrs: Hash = {key: value, ...}
#
# -- CRUD --
# user_create(username, password = nil, **userdata) -> userdata [writable]
# user_read(username) -> userdata? [readable]
# user_update(username, **userdata) -> userdata? [writeable]
# user_delete(username) -> userdata? [writable]
#
# user_auth(username, password) -> bool [authenticatable]
#
# user_change_password(username, password) -> bool [password_changeable]
# user_generate_code(username) -> codes? [password_changeable]
#
# user_lock(username) -> bool [lockable]
# user_unlock(username, password = nil) -> bool [lockable]
#
# user_list -> Array[username] [readable]
# user_search(query) -> Array[username] [readable]
#
# user_group_list(username) -> Array[groupname] [readable, group]
#
# x group_create(groupname, **groupdata) -> groupdata [writable]
# group_read(groupname) -> groupdata? [readable]
# x group_update(groupname, **groupdata) -> groupdata? [writeable]
# x group_delete(groupname) -> groupdata? [writable]
# group_list -> Array[groupname]
#
# member_list(groupname) -> Array[usernames]
# member_add(groupname, username) -> bool
# member_remove(groupname, username) -> bool
#

require 'logger'

require_relative 'abstract_adapter/param_type'
require_relative '../utils/hash_array'

module Yuzakan
  module Adapters
    class AbstractAdapter
      extend Yuzakan::Utils::HashArray

      class << self
        attr_accessor :abstract_adapter, :hidden_adapter, :name, :label, :version, :params

        def selectable?
          !abstract_adapter && !hidden_adapter
        end

        def abstract?
          nil | abstract_adapter
        end

        def param_types
          @param_types ||= params&.map do |data|
            ParamType.new(**data)
          end
        end

        def param_type_by_name(name)
          param_types_map.fetch(name)
        end

        def param_types_map
          @param_types_map ||= param_types&.to_h do |type|
            [type.name, type]
          end
        end

        def normalize_params(params)
          param_types.to_h do |param_type|
            [param_type.name, param_type.load_value(params[param_type.name])]
          end
        end
      end

      self.abstract_adapter = true

      def initialize(params, logger: Logger.new(STDERR))
        @params = params
        @logger = logger
      end

      def check
        raise NotImplementedError
      end

      def user_create(_username, _password = nil, **_userdata)
        raise NotImplementedError
      end

      def user_read(_username)
        raise NotImplementedError
      end

      def user_update(_username, **_userdata)
        raise NotImplementedError
      end

      def user_delete(_username)
        raise NotImplementedError
      end

      def user_auth(_username, _password)
        raise NotImplementedError
      end

      def user_change_password(_username, _password)
        raise NotImplementedError
      end

      def user_generate_code(_username)
        raise NotImplementedError
      end

      def user_lock(_username)
        raise NotImplementedError
      end

      def user_unlock(_username, _password = nil)
        raise NotImplementedError
      end

      def user_list
        raise NotImplementedError
      end

      def user_search(query)
        raise NotImplementedError
      end

      def user_group_list(username)
        raise NotImplementedError
      end

      def group_create(groupname, **groupdata)
        raise NotImplementedError
      end

      def group_list
        raise NotImplementedError
      end

      def member_list(groupname)
        raise NotImplementedError
      end

      def member_add(groupname, username)
        raise NotImplementedError
      end

      def member_remove(groupname, username)
        raise NotImplementedError
      end
    end
  end
end
