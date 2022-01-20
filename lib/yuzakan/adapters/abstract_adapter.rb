# adapter
#
# initialize(params)
# check -> true or false
#
# attrs:
#   name: String = username
#   display_name: String = display name
#   email: String = mail address
#   locked: ?bool
#   disabled: ?bool
#   unmanageable: ?bool
#   mfa: ?bool
#   "key" => value
#   ...
#
# CRUD
# create(username, password = nil, **attrs) -> attrs [writable]
# read(username) -> attrs or nil [readable]
# update(username, **attrs) -> attrs [writeable]
# delete(username) -> nil [writable]
#
# auth(username, password) -> bool [authenticatable]
#
# change_password(username, password) -> attrs or nil [password_changeable]
# generate_code(username) -> codes or nil [password_changeable]
#
# lock(username) -> nil [lockable]
# unlock(username, password = nil) -> nil [lockable]
#
# list -> usernames [readable]
#
# search(query) -> usernames [readable]
#
# group_attrs:
#   name: String = username
#   display_name: String = display name
#   disabled: ?bool
#   unmanageable: ?bool
#   "key" => value
#   ...
#
# group_create(groupname, **group_attrs) -> group_attrs or nil [writable]
# group_read(groupname) -> group or nil [readable]
# group_update(groupname, **group_attrs) -> group_attrs or nil [writeable]
# group_delete(groupname) -> group or nil [writable]
# group_list -> groupnames
#
# member_list(groupname)
# member_insert(groupname, username)
# member_delete(groupname, username)
#
# params is Hash Array
# - name: 識別名
# - label: 表示名
# - description: 説明
# - type: 型
#     - :boolean, :string, :text, :intger, :float, :date, :time, :datetime,
#       :file
# - input: form inputのタイプ
#     - :text, :password, email, ...
#     - 省略時はtypeによって自動決定
# - required: 必須かどうか (デフォルト: fales)
# - placeholder: 入力時のプレースホルダー
# - input:
#     - :free, select, button
# - list: string等で自由入力ではなく一覧からの選択になる。
# - default: 新規作成時のデフォルト値
# - encrypted: 暗号化して保存するか (:string, :text, :fileのみ指定可能、
#              デフォルト: fales)

module Yuzakan
  module Adapters
    class Error < RuntimeError
    end

    class ParamType
      class ListItem
        attr_reader :name, :label, :value, :deprecated

        def initialize(name:, value:, label: nil, deprecated: false)
          @name = name.intern
          @label = label || name.to_s
          @value = value
          @deprecated = deprecated
        end

        def to_json(...)
          {name: name, label: label, value: value, deprecated: deprecated}.to_json(...)
        end
      end

      TYPE_INPUTS = {
        boolean: 'checkbox',
        string: 'text',
        text: 'textarea',
        integer: 'number',
      }.freeze

      attr_reader :name, :label, :description,
                  :type, :default, :list, :encrypted,
                  :input, :required, :placeholder

      def initialize(name:, type:, label: nil, description: nil, default: nil, list: nil, encrypted: false,
                     input: nil, required: nil, placeholder: nil)
        @name = name.intern
        @label = label || name.to_s
        @description = description

        @type = type
        @default = default

        @list = list&.map do |item|
          if item.is_a?(ParamType::ListItem)
            item
          else
            ParamType::ListItem.new(**item)
          end
        end
        @encrypted = encrypted

        @input = input || TYPE_INPUTS.fetch(type)

        @required =
          if required.nil?
            default.nil?
          else
            required
          end

        @placeholder = placeholder || default
      end

      def to_json(...)
        {
          name: name,
          label: label,
          description: description,

          type: type,
          default: default,
          list: list,
          encrypted: encrypted,

          input: input,
          placeholder: placeholder,
          required: required,
        }.to_json(...)
      end
    end

    class AbstractAdapter
      class << self
        attr_accessor :abstract_adapter, :hidden_adapter

        def label
          self::LABEL || raise(NotImplementedError)
        end

        def selectable?
          !abstract_adapter && !hidden_adapter
        end

        def abstract?
          !!abstract_adapter
        end

        def param_types
          @param_types ||= self::PARAM_TYPES.map do |data|
            ParamType.new(**data)
          end
        end

        def param_type_by_name(name)
          param_types_map.fetch(name)
        end

        def param_types_map
          @param_types_map ||= param_types.to_h do |type|
            [type.name, type]
          end
        end

        # def self.params
        #   self::PARAMS || []
        # end

        # def self.name_param_map
        #   @name_param_map ||= params.map { |param| [param[:name].intern, param] }.to_h
        # end

        # def self.param_by_name(name)
        #   name_param_map&.fetch(name)
        # end

        def decrypt(encrypted_params)
          encrypted_params.to_h do |name, value|
            param_type = param_type_by_name(name)
            if param_type.encrypted
              result = Decrypt.new.call(encrypted: value)
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
                  {max: 4096}
                when :text
                  {max: 0}
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

      def create(_username, _password = nil, **_attrs)
        raise NotImplementedError
      end

      def read(_username)
        raise NotImplementedError
      end

      def udpate(_username, **_attrs)
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
