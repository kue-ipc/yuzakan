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
#   attr_reader label: String
#   attr_reader email: String
#   attr_reader locked: bool?
#   attr_reader unmanageable: bool?
#   attr_reader mfa: bool?
#   attr_reader attrs: Hash[Symbol, untyped]
#
# GroupData:
#   attr_reader name: String
#   attr_reader label: String
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
require "dry/core/class_attributes"
require "dry/configurable"
require "hanami/utils/string"

module Yuzakan
  class Adapter
    extend Dry::Configurable
    extend Dry::Core::ClassAttributes

    # nested classes

    class AdapterError < StandardError
    end

    class VlaidationError < StandardError
    end

    UserData = Data.define(:name, :primary_group, :groups,
      :label, :email, :locked, :unmanageable, :mfa, :attrs) do
      def initialize(name: nil, primary_group: nil, groups: [],
        label: nil, email: nil,
        locked: false, unmanageable: false, mfa: false, attrs: {})
        super
      end
    end

    GroupData = Data.define(:name, :label, :unmanageable, :attrs) do
      def initialize(name: nil, label: nil, unmanageable: false,
        attrs: {})
        super
      end
    end

    # class attributes and methods

    setting :contract_class
    setting :encrypted_keys, default: []
    setting :default_params, default: {}

    defines :version, type: Dry::Types["strict.string"]
    defines :abstract, :hidden, type: Dry::Types["strict.bool"]
    defines :group, :primary_group, type: Dry::Types["strict.bool"]

    version "0.0.0"
    abstract false
    hidden false
    group false
    primary_group false

    def self.adapter_name
      @adapter_name ||= Hanami::Utils::String.underscore(Hanami::Utils::String.demodulize(name))
    end

    def self.label
      Hanami.app["i18n"].t("adapters.#{adapter_name}.label", default: adapter_name)
    end

    def self.abstract?
      !!abstract
    end

    def self.hidden?
      !!hidden
    end

    def self.selectable?
      !(abstract || hidden)
    end

    def self.has_group?
      !!group
    end

    def self.has_primary_group?
      group && primary_group
    end

    # define validation contract use JSON schema
    def self.json(&block)
      config.contract_class = Class.new(Yuzakan::Validation::Contract) { json(&block) }
    end

    def self.validate(params)
      raise "Contract class is not defined. Use `json` method to define it." if config.contract_class.nil?

      config.contract_class.new.call(params)
    end

    def self.schema
      raise "Contract class is not defined. Use `json` method to define it." if config.contract_class.nil?

      config.contract_class.schema
    end

    # set deafault parameter value
    def self.set_default_param(name, value)
      config.default_params[name] = value
    end

    def self.default_params
      config.default_params
    end

    # add encrypted key
    def self.add_encrypted_key(name)
      config.encrypted_keys << name
    end

    def self.encrypted_keys
      config.encrypted_keys
    end

    # parse and validate parameters
    def self.parse_params(params)
      validated_params = validate(params)
      raise VlaidationError, validated_params.errors.to_h if validated_params.failure?

      default_params.merge(validated_params.to_h).to_h do |key, value|
        if encrypted_keys.include?(key)
          case Hanami.app["operations.decrypt"].call(value)
          in Success(decrypted_value)
            [key, decrypted_value]
          in Failure[:error, e]
            raise AdapterError, "Failed to decrypt value for key '#{key}': #{e.message}"
          end
        else
          [key, value]
        end
      end
    end

    # instance attributes and methods

    attr_reader :params, :group, :logger

    def initialize(params, group: false, logger: Logger.new($stderr))
      @params = self.class.parse_params(params).freeze
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
