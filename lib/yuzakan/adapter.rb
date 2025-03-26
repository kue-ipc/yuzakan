# frozen_string_literal: true

# adapter
#
# initialize(params)
# check -> bool
#
# UserData:
#   attr_reader name: String
#   attr_reader primary_group: String?
#   attr_reader groups: Array[String]
#   attr_reader display_name: String
#   attr_reader email: String
#   attr_reader locked: bool?
#   attr_reader unmanageable: bool?
#   attr_reader mfa: bool?
#   attr_reader attrs: Hash[Symbol, untyped]
#
# GroupData:
#   attr_reader name: String
#   attr_reader display_name: String
#   attr_reader unmanageable: bool?
#   attr_reader attrs: Hash[Symbol, untyped]
#
# -- CRUD --
# user_create(username, userdata, password: nil) -> userdata? [writable]
#   ... if user exists, do nothing and return nil
# user_read(username) -> userdata? [readable]
# user_update(username, userdata) -> userdata? [writeable]
# user_delete(username) -> userdata? [writable]
#
# user_rename(oldname, newname)
#
# user_auth(username, password) -> bool? [authenticatable]
# user_change_password(username, password) -> bool? [password_changeable]
#
# user_reset_mfa -> bool? [mfa_changeable]
# user_generate_code(username) -> codes? [mfa_changeable]
#
# user_lock(username) -> bool? [lockable]
# user_unlock(username, password = nil) -> bool? [lockable]
#
# user_list -> Array[username] [readable]
# user_search(query) -> Array[username] [readable]
#
# group_create(groupname, groupdata) -> groupdata? [writable]
#   ... if group exists, do nothing and return nil
# group_read(groupname) -> groupdata? [readable]
# group_update(groupname, groupdata) -> groupdata? [writeable]
# group_delete(groupname) -> groupdata? [writable]
# group_list -> Array[groupname] [readable]
# group_search(query) -> Array[groupname] [readable]
#
# member_list(groupname) -> Array[usernames] [readable]
# member_add(groupname, username) -> bool [writable]
# member_remove(groupname, username) -> bool [writable]
#

require "logger"

module Yuzakan
  class Adapter
    extend Yuzakan::Utils::HashArray
    class AdapterError < StandardError
    end

    UserData = Data.define(:name, :primary_group, :groups,
      :display_name, :email, :locked, :unmanageable, :mfa, :attrs) {
      def initialize(name: nil, primary_group: nil, groups: [],
        display_name: nil, email: nil,
        locked: false, unmanageable: false, mfa: false, attrs: {})
        super
      end
    }

    GroupData = Data.define(:name, :display_name, :unmanageable, :attrs) {
      def initialize(name: nil, display_name: nil, unmanageable: false,
        attrs: {})
        super
      end
    }

    class << self
      attr_accessor :name, :display_name, :version, :params

      def label_name
        if display_name
          "#{display_name} (#{name})"
        else
          name
        end
      end

      def label
        display_name || name
      end

      def abstract(bool = nil)
        @abstract_adapter = bool
      end

      def hidden(bool = nil)
        @hidden_adapter = bool
      end

      def group(type)
        @group = type
      end

      def abstract?
        !!@abstract_adapter
      end

      def hidden?
        !!@hidden_adapter
      end

      def selectable?
        !(abstract? || hidden?)
      end

      def has_group?
        !!@group
      end

      def has_primary_group?
        @group == :primary
      end

      def param_types
        @param_types ||= params&.map { |data|
          ParamType.new(**data)
        }
      end

      def param_type_by_name(name)
        param_types_map.fetch(name)
      end

      def param_types_map
        @param_types_map ||= param_types&.to_h { |type|
          [type.name, type]
        }
      end

      def normalize_params(params)
        params = params.to_h(&:to_a) if params.is_a?(Array)
        params = params.transform_keys(&:intern)
        param_types.to_h do |param_type|
          [param_type.name, param_type.load_value(params[param_type.name])]
        end
      end
    end

    abstract true

    attr_reader :logger

    def initialize(params, group: false, logger: Logger.new($stderr))
      @params = self.class.normalize_params(params)
      @group = group
      @logger = logger
    end

    def has_group?
      @group && self.class.has_group?
    end

    def has_primary_group?
      has_group? && self.class.has_primary_group?
    end

    # abstract instance methods
    # rubocop: disable Lint/UnusedMethodArgument
    def check
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_create(username, userdata, password: nil)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_read(username)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_update(username, userdata)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_delete(username)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_auth(username, password)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_change_password(username, password)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_generate_code(username)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_lock(username)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_unlock(username, password: nil)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_list
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def user_search(query)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def group_create(groupname, groupdata)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def group_read(groupname)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def group_update(groupname, groupdata)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def group_delete(groupname)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def group_list
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def group_search(query)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def member_list(groupname)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def member_add(groupname, username)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end

    def member_remove(groupname, username)
      raise NoMethodError, "Not implement #{self.class}##{__method__}"
    end
    # rubocop: enable Lint/UnusedMethodArgument
  end
end
