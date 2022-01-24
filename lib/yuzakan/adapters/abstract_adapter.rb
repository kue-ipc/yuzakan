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
# create(username, password = nil, **userdata) -> userdata [writable]
# read(username) -> userdata or nil [readable]
# update(username, **userdata) -> userdata [writeable]
# delete(username) -> nil [writable]
#
# auth(username, password) -> bool [authenticatable]
#
# change_password(username, password) -> nil [password_changeable]
# generate_code(username) -> codes or nil [password_changeable]
#
# lock(username) -> nil [lockable]
# unlock(username, password = nil) -> nil [lockable]
#
# list -> usernames [readable]
#
# search(query) -> usernames [readable]
#
# groupdate:
#   name: String = groupname
#   display_name: String = display name
#   disabled: ?bool
#   unmanageable: ?bool
#   attrs: Hash = {key: value, ...}
#
# group_create(groupname, **groupdata) -> groupdata or nil [writable]
# group_read(groupname) -> group or nil [readable]
# group_update(groupname, **groupdata) -> groupdata or nil [writeable]
# group_delete(groupname) -> group or nil [writable]
# group_list -> groupnames
#
# member_list(groupname)
# member_add(groupname, username)
# member_delete(groupname, username)
#

require_relative 'param_type'
require_relative '../utils/hash_array'

module Yuzakan
  module Adapters
    class Error < RuntimeError
    end

    class AbstractAdapter
      extend Yuzakan::Utils::HashArray

      class << self
        attr_accessor :abstract_adapter, :hidden_adapter, :label, :params

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

        def decrypt(encrypted_params)
          encrypted_params.to_h do |name, value|
            param_type = param_type_by_name(name)
            if param_type.encrypted
              result = Decrypt.new(text: true).call(encrypted: value)
              raise Yuzakan::Adapters::Error, result.errors if result.failure?

              [name, result.data]
            else
              [name, value]
            end
          end
        end

        def encrypt(plain_params)
          plain_params.to_h do |name, value|
            param_type = param_type_by_name(name)
            if param_type.encrypted
              encrypt_opts =
                case param_type.type
                when :string
                  {max: 4096, text: true}
                when :text
                  {max: 0, text: true}
                else
                  raise Yuzakan::Adapters::Error, "can not ecrypt type: #{param_type.type}"
                end
              encrypt = Encrypt.new(**encrypt_opts)
              result = encrypt.call(data: value)
              raise Yuzakan::Adapters::Error, result.errors if result.failure?

              [name, result.encrypted]
            else
              [name, value]
            end
          end
        end

        def normalize_params(params)
          param_types.to_h do |param_type|
            name = param_type.name
            value =
              if params[name].nil? ||
                 (params[name].is_a?(String) && params[name].empty?)
                param_type.default
              else
                params[name]
              end
            [name, value]
          end
        end
      end

      self.abstract_adapter = true

      def initialize(params)
        @params = self.class.normalize_params(params)
      end

      def check
        raise NotImplementedError
      end

      def create(_username, _password = nil, **_userdata)
        raise NotImplementedError
      end

      def read(_username)
        raise NotImplementedError
      end

      def udpate(_username, **_userdata)
        raise NotImplementedError
      end

      def delete(_username)
        raise NotImplementedError
      end

      def auth(_username, _password)
        raise NotImplementedError
      end

      def change_password(_username, _password)
        raise NotImplementedError
      end

      def generate_code(_username)
        raise NotImplementedError
      end

      def lock(_username)
        raise NotImplementedError
      end

      def unlock(_username, _password = nil)
        raise NotImplementedError
      end

      def locked?(_username)
        raise NotImplementedError
      end

      def list
        raise NotImplementedError
      end
    end
  end
end
