# adapter
#
# initialize(params)
# check -> true or false
#
# userdata:
#   name: String = username
#   display_name: String = display name
#   email: String = mail address
#   locked: ?bool
#   disabled: ?bool
#   unmanageable: ?bool
#   mfa: ?bool
#   attrs: Hash = {key: value, ...}
#
# groupdate:
#   name: String = groupname
#   dislay_name: String = display name
#
# -- CRUD --
# user_create(username, password = nil, **userdata) -> userdata [writable]
# user_read(username) -> userdata or nil [readable]
# user_update(username, **userdata) -> userdata or nil [writeable]
# user_delete(username) -> userdata or nil [writable]
#
# user_auth(username, password) -> bool [authenticatable]
#
# user_change_password(username, password) -> userdata or nil [password_changeable]
# user_generate_code(username) -> codes or nil [password_changeable]
#
# user_lock(username) -> userdata or nil [lockable]
# user_unlock(username, password = nil) -> userdata or nil [lockable]
#
# user_list -> usernames [readable]
# user_search(query) -> usernames [readable]
#
# groupdate:
#   name: String = groupname
#   display_name: String = display name
#   disabled: ?bool
#   unmanageable: ?bool
#   attrs: Hash = {key: value, ...}
#
# x group_create(groupname, **groupdata) -> groupdata or nil [writable]
# group_read(groupname) -> groupdata or nil [readable]
# x group_update(groupname, **groupdata) -> groupdata or nil [writeable]
# x group_delete(groupname) -> groupdata or nil [writable]
# group_list -> groupnames
#
# member_list(groupname) -> usernames
# member_add(groupname, username)
# member_remove(groupname, username)
#

require 'logger'

require_relative 'error'
require_relative 'param_type'
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
    end
  end
end
