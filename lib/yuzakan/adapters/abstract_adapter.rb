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
# create(username, password = nil, **attrs): () -> attrs [writable]
# read(username) -> attrs or nil [readable]
# update(username, **attrs) -> attrs [writeable]
# delete(username) -> nil [writable]
#
# auth(username, password) -> bool [authenticatable]
#
# change_password(username, password) -> nil [password_changeable]
# generate_code(username) -> codes [password_changeable]
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

    class AbstractAdapter
      def self.label
        raise NotImplementedError
      end

      def self.selectable?
        false
      end

      def self.params
        @params || raise(NotImplementedError)
      end

      def self.params=(params)
        @params = params
        @name_param_map =
          params.map { |param| [param[:name].intern, param] }.to_h
      end

      def self.param_by_name(name)
        @name_param_map&.fetch(name)
      end

      def self.decrypt(data)
        data.map do |key, value|
          param = @name_param_map[key]
          if param&.[](:encrypted)
            result = Decrypt.new.call(encrypted: value)
            raise Yuzakan::Adapters::Error, result.errors if result.failure?

            [key, result.data]
          else
            [key, value]
          end
        end.to_h
      end

      def self.encrypt(data)
        data.map do |key, value|
          param = @name_param_map[key]
          if param&.[](:encrypted)
            encrypt_opts =
              case param[:type]
              when :string
                {max: 4096}
              when :text
                {max: 0}
              end
            encrypt = Encrypt.new(**encrypt_opts)
            result = encrypt.call(data: value)
            raise Yuzakan::Adapters::Error, result.errors if result.failure?

            [key, result.encrypted]
          else
            [key, value]
          end
        end.to_h
      end

      def initialize(params)
        @params = self.class.decrypt(params)
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
